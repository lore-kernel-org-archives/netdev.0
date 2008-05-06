From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 02/18] flag parameters: socket and socketpair
Date: Tue, 6 May 2008 12:43:15 +0100
Message-ID: <20080506124315.4567ee73@core>
References: <200805050342.m453gktl029817@devserv.devel.redhat.com>
	<20080505185850.789d870a.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0805051910050.20837@alien.or.mcafeemobile.com>
	<20080505191725.89faed88.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Davide Libenzi <davidel@xmailserver.org>,
	Ulrich Drepper <drepper@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, mtk.manpages@gmail.com,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:36710 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755000AbYEFLwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 07:52:42 -0400
In-Reply-To: <20080505191725.89faed88.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > 	type = flag_remap(type, &fflags, SOCK_whatever, O_whatever);
> > > 	type = flag_remap(type, &fflags, SOCK_whatever2, O_whatever2);
> > > 
> > > ?
> > 
> > I think it is better to keep it able to remap more than one flag, with a 
> > single call, that is table driven.
> > 
> 
> The table-driven approach is slower for one and probably two bits and it is
> somewhat less readable.  What do we gain in return for this?

Acute over-engineering ?

We've got lots of space for flag bits so surely we can do remap with a
shift and mask.

	flags = (type >> SOCK_FLAG_SHIFT) & SOCK_FLAG_MASK;
	type = type & SOCK_TYPE_MASK

For most boxes

SOCK_TYPE_MASK can easily be 0xFF
SOCK_FLAG_MASK O_CLOEXEC
SOCK_FLAG_SHIFT 0

and tweaked a bit depending what other flags we want.

In Linux we could actually just do SOCK_STREAM|O_CLOEXEC but that would be
bad news for portability to other OS where the trick might well not work.


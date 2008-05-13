From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 18/18] flag parameters: check magic constants
Date: Mon, 12 May 2008 21:01:41 -0700
Message-ID: <20080512210141.bf00ada4.akpm@linux-foundation.org>
References: <200805062118.m46LI74j004096@devserv.devel.redhat.com>
	<20080512201341.9ead6a9a.akpm@linux-foundation.org>
	<482910FA.1080703@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davidel@xmailserver.org, mtk.manpages@gmail.com,
	torvalds@linux-foundation.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59664 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750878AbYEMECB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 00:02:01 -0400
In-Reply-To: <482910FA.1080703@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 May 2008 20:54:34 -0700 Ulrich Drepper <drepper@redhat.com> wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Andrew Morton wrote:
> >> +	BUILD_BUG_ON(SOCK_NONBLOCK & SOCK_TYPE_MASK);
> > 
> > The fifth assertion triggers with alpha allmodconfig.
> 
> This means the simple approach won't work for alpha.
> 
> The question is how to solve it?  I suggest the following:
> 
> - - define SOCK_NONBLOCK to some value > 16 in include/asm-alpha/socket.h
> 
> - - add #ifndef SOCK_NONBLOCK around the definition in include/linux/net.h

With a comment, please.

> - - in sys_socket, sys_socketpair, sys_paccept
> 
>    int fflags = flags;
>    if (SOCK_NONBLOCK != O_NONBLOCK && (flags & SOCK_NONBLOCK)) {
>      fflags &= ~SOCK_NONBLOCK;
>      fflags |= O_NONBLOCK;
>    }
> 
>   and use fflags instead of flags in the places where we pass it on.
> 
> This has no costs on platforms other than alpha.
> 
> Shall I sent a patch?

Sounds reasonable.

From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: 2.6.31-rc5: Reported regressions from 2.6.30
Date: Mon, 3 Aug 2009 16:31:08 +0200
Message-ID: <20090803143108.GA12041@cmpxchg.org>
References: <Su1q3S6JjyO.A.jeB.hcgdKB@chimera> <alpine.LFD.2.01.0908021456430.3352@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>,
	Mikael Pettersson <mikpe@it.uu.se>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmpxchg.org ([85.214.51.133]:39633 "EHLO cmpxchg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932150AbZHCOdq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Aug 2009 10:33:46 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.01.0908021456430.3352@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 02, 2009 at 03:22:01PM -0700, Linus Torvalds wrote:

> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13815
> > Subject		: emacs -nw compilation doesn't show the error message
> > Submitter	: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > Date		: 2009-07-23 06:22 (11 days old)
> > First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=d945cb9cce20ac7143c2de8d88b187f62db99bdc
> 
> Same old pty bug, same fix: commit e043e42bdb.
> 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13813
> > Subject		: Hangups in n_tty_read()
> > Submitter	: Johannes Weiner <hannes@cmpxchg.org>
> > Date		: 2009-07-16 18:48 (18 days old)
> > References	: http://marc.info/?l=linux-kernel&m=124777019920579&w=4
> 
> Hmm. Worth testing that same fix, although the symptoms here are not 
> exactly the same.

Hm, I had no debugging enabled, but I think a silent hang in

	pty_write()
	  tty_flip_buffer_push()
	    flush_to_ldisc()

can cause the receiving side

	tty_read()
	  n_tty_read()

to wait forever for updates.  I haven't looked closely.  It seems to
be gone with your latest master in any case.

	Hannes

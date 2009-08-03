From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: 2.6.31-rc5: Reported regressions from 2.6.30
Date: Mon, 3 Aug 2009 18:09:58 +0200
Message-ID: <200908031810.00505.rjw@sisk.pl>
References: <Su1q3S6JjyO.A.jeB.hcgdKB@chimera> <alpine.LFD.2.01.0908021456430.3352@localhost.localdomain> <20090803143108.GA12041@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Mikael Pettersson <mikpe-1zs4UD6AkMk@public.gmane.org>
To: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090803143108.GA12041-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 03 August 2009, Johannes Weiner wrote:
> On Sun, Aug 02, 2009 at 03:22:01PM -0700, Linus Torvalds wrote:
> 
> > > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13815
> > > Subject		: emacs -nw compilation doesn't show the error message
> > > Submitter	: Aneesh Kumar K.V <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> > > Date		: 2009-07-23 06:22 (11 days old)
> > > First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=d945cb9cce20ac7143c2de8d88b187f62db99bdc
> > 
> > Same old pty bug, same fix: commit e043e42bdb.
> > 
> > > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13813
> > > Subject		: Hangups in n_tty_read()
> > > Submitter	: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
> > > Date		: 2009-07-16 18:48 (18 days old)
> > > References	: http://marc.info/?l=linux-kernel&m=124777019920579&w=4
> > 
> > Hmm. Worth testing that same fix, although the symptoms here are not 
> > exactly the same.
> 
> Hm, I had no debugging enabled, but I think a silent hang in
> 
> 	pty_write()
> 	  tty_flip_buffer_push()
> 	    flush_to_ldisc()
> 
> can cause the receiving side
> 
> 	tty_read()
> 	  n_tty_read()
> 
> to wait forever for updates.  I haven't looked closely.  It seems to
> be gone with your latest master in any case.

Thanks, closed (in fact I closed it earlier already).

Rafael

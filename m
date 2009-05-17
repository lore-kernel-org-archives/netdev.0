From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: 2.6.30-rc6: Reported regressions from 2.6.29
Date: Sun, 17 May 2009 12:34:21 +0200
Message-ID: <200905171234.23436.rjw@sisk.pl>
References: <_AjETDMbIoL.A.DcH.RYzDKB@chimera> <20090517073327.GC1583@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, Martin Bammer <mrb74-RbZlAiThDcE@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Jeff Mahoney <jeffm-IBi9RG/b67k@public.gmane.org>,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090517073327.GC1583-X9Un+BFzKDI@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 17 May 2009, Ingo Molnar wrote:
> 
> * Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org> wrote:
> 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13325
> > Subject		: 2.6.30-rc kills my box hard - and lockdep chains
> > Submitter	: Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>
> > Date		: 2009-05-14 15:49 (3 days old)
> > References	: http://marc.info/?l=linux-kernel&m=124231630701394&w=4
> 
> Jonathan, there's a side-issue reported there, us running out of 
> lockdep space. Could you try this commit from -tip:
> 
> d80c19d: lockdep: increase MAX_LOCKDEP_ENTRIES and MAX_LOCKDEP_CHAINS
> 
> (which i'll get to Linus in the next ~24 hours.) Maybe that allows 
> lockdep to report the reason for the deadlock.
> 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13321
> > Subject		: kernel crash with NULL pointer when boot
> > Submitter	: Martin Bammer <mrb74-RbZlAiThDcE@public.gmane.org>
> > Date		: 2009-05-16 12:37 (1 days old)
> > References	: http://lkml.org/lkml/2009/5/16/100
> 
> that crash is in reiserfs_for_each_xattr(), during sys_unlink()'s 
> xattr teardown.
> 
> There's been a good deal of reiserfs changes in this cycle - some 
> touch the xattr code as well. Some of them fairly late in the cycle, 
> in the last two weeks:
> 
>  earth4:~/tip> gll v2.6.29..linus --since=two-weeks-ago fs/reiserfs/
>  2a32ceb: Fix races around the access to ->s_options
>  677c9b2: reiserfs: remove privroot hiding in lookup
>  b82bb72: reiserfs: dont associate security.* with xattr files
>  ab17c4f: reiserfs: fixup xattr_root caching
>  edcc37a: Always lookup priv_root on reiserfs mount and keep it
>  5a6059c: reiserfs: Expand i_mutex to enclose lookup_one_len
> 
> Martin, you could try a blind revert of say ... ab17c4f, which looks 
> the most suspect and which is also a rather large commit.
> 
> Or/and you could try a bisect - perhaps accelerated via:
> 
>    git bisect start fs/reiserfs/

I think there's a fix already for this in the works, but it hasn't been merged
yet.  It looks like Jeff has just posted some reiserfs fixes. :-)

> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13297
> > Subject		: kernel panic -  not syncing : fatel exception in interupt
> > Submitter	: rob <rob1-z2Ut7v/pTR/vt0rt8C/ehw@public.gmane.org>
> > Date		: 2009-05-12 19:34 (5 days old)
> > References	: http://marc.info/?l=linux-kernel&m=124216126903309&w=4
> 
> tainted crash, but probably legit. It does show some badness in an 
> old-IDE legacy codepath:
> 
> [<c0371865>] error_code+0x65/0x6c
> [<c0110155>] do_page_fault+0x0/0x1e0
> [<c027dafc>] ide_complete_rq+0xf/0x3b
> [<c02870a0>] cdrom_newpc_intr+0x64d/0x6cd
> [<c0286a53>] cdrom_newpc_intr+0x0/0x6cd
> [<c027dcc2>] ide_intr+0x109/0x161
> [<c0132298>] handle_IRQ_event+0x54/0xc7
> [<c013354a>] handle_level_irq+0x4f/0x85
> [<c0103df7>] handle_irq+0x17/0x20
> [<c0103da5>] do_IRQ+0x2b/0x66
> [<c0102be9>] common_interupt+0x29/0x30
> [<c0480000>] cmd40x_init+0x2ac/0x38d
> [<c0106db3>] default_idle+0x25/0x38
> [<c01019be>] cpu_idle+0x19/0x2d
> [<c0468907>] start_kernel+0x23f/0x242
> 
> report subject line is too unspecific, it should be changed to 
> something like:
> 
>   legacy IDE cmd40x related bootup crash
> 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13296
> > Subject		: Lockdep violation at cleanup_workqueue_thread during suspend
> > Submitter	: Zdenek Kabelac <zdenek.kabelac-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date		: 2009-05-12 7:59 (5 days old)
> > References	: http://marc.info/?l=linux-kernel&m=124211522525625&w=4
> 
> looks like wireless related - the dependency that connects the 
> locks in a wrong way appears to be:
> 
>  -> #2 (cfg80211_mutex){+.+.+.}:
>         [<ffffffff80271a64>] __lock_acquire+0xc64/0x10a0
>         [<ffffffff80271f38>] lock_acquire+0x98/0x140
>         [<ffffffff8054e78c>] __mutex_lock_common+0x4c/0x3b0
>         [<ffffffff8054ebf6>] mutex_lock_nested+0x46/0x60
>         [<ffffffffa007e66a>] reg_todo+0x19a/0x590 [cfg80211]
>         [<ffffffff80258f18>] worker_thread+0x1e8/0x3a0
>         [<ffffffff8025dc3a>] kthread+0x5a/0xa0
>         [<ffffffff8020d23a>] child_rip+0xa/0x20
> 
> (havent checked deeper)
> 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13245
> > Subject		: possible circular locking dependency detected
> > Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date		: 2009-05-04 16:56 (13 days old)
> 
> same as #13296 above. (The one above should be merged into this one 
> i guess)

Yes, I've merged the two.

> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13126
> > Subject		: BUG: MAX_LOCKDEP_ENTRIES too low! when mounting rootfs
> > Submitter	: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date		: 2009-04-15 12:43 (32 days old)
> > References	: http://marc.info/?l=linux-kernel&m=123979949820538&w=4
> 
> should be resolved via the lockdep space extension fix.
> 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13118
> > Subject		: iptables very slow after commit 784544739a25c30637397ace5489eeb6e15d7d49
> > Submitter	: Jeff Chua <jeff.chua.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date		: 2009-04-10 16:05 (37 days old)
> > References	: http://lkml.org/lkml/2009/4/10/111
> > 		  http://lkml.org/lkml/2009/4/25/83
> > Handled-By	: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
> 
> solved by:
> 
>  commit 942e4a2bd680c606af0211e64eb216be2e19bf61
>  Author: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
>  Date:   Tue Apr 28 22:36:33 2009 -0700
> 
>     netfilter: revised locking for x_tables

Already closed.

> commit log does not credit reporters and testers and does not 
> mention bugzilla id.

Sigh.

> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13116
> > Subject		: Can't boot with nosmp
> > Submitter	: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
> > Date		: 2009-04-15 4:18 (32 days old)
> > References	: http://marc.info/?l=linux-kernel&m=123976917817920&w=4
> > Handled-By	: Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> I think this might be fixed by:
> 
>  d6de2c8: async: Fix module loading async-work regression

That would be good to verify.  Stephen?

> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13107
> > Subject		: LTP 20080131 causes defunct processes w/2.6.30-rc1
> > Submitter	: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
> > Date		: 2009-04-09 15:43 (38 days old)
> > First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=b3bfa0cba867f23365b81658b47efd906830879b
> > References	: http://marc.info/?l=linux-kernel&m=123929187208953&w=4
> > 		  http://lkml.org/lkml/2009/4/10/193
> > Handled-By	: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> 
> Oleg says in that thread that it's as-designed, and followup 
> questions were not replied to (yet).
> 
> But ... a relevant seeming commit has been bisected to so this 
> shouldnt be ignored that easily.
> 
> Andrew, you merged the commit that was bisected to:
> 
>   From b3bfa0cba867f23365b81658b47efd906830879b Mon Sep 17 00:00:00 2001
>   From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
>   Date: Thu, 2 Apr 2009 16:58:08 -0700
>   Subject: [PATCH] signals: protect cinit from blocked fatal signals
> 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13068
> > Subject		: Lockdep warining in inotify_dev_queue_event
> > Submitter	: Sachin Sant <sachinp-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
> > Date		: 2009-04-05 12:37 (42 days old)
> > References	: http://marc.info/?l=linux-kernel&m=123893439229272&w=4
> 
> should be fixed by:
> 
> 381a80e: inotify: use GFP_NOFS in kernel_event() to work around a lockdep false-positive

Closed.

Thanks a lot,
Rafael

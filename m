From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.35-rc2-git2: Reported regressions from 2.6.34
Date: Wed, 9 Jun 2010 10:55:38 +0200
Message-ID: <201006091055.38462.rjw@sisk.pl>
References: <Rlf_Qjov7bG.A.a8F.I8rDMB@chimera> <alpine.LFD.2.00.1006081814240.4506@i5.linux-foundation.org> <4C0F4872.7090909@fusionio.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Carl Worth <cworth@cworth.org>, Eric Anholt <eric@anholt.net>,
	Venkatesh Pallipadi <venki@google.com>,
	Dave Airlie <airlied@gmail.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	Ingo Molnar <mingo@elte.hu>,
	David =?iso-8859-15?q?H=E4rdeman?= <david@hardeman.nu>,
	Mauro Carvalho Chehab <mchehab@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>
To: Jens Axboe <jaxboe@fusionio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:41160 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753197Ab0FIIyF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jun 2010 04:54:05 -0400
In-Reply-To: <4C0F4872.7090909@fusionio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 09 June 2010, Jens Axboe wrote:
> On 2010-06-09 03:53, Linus Torvalds wrote:
> >> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16129
> >> Subject	: BUG: using smp_processor_id() in preemptible [00000000] code: jbd2/sda2
> >> Submitter	: Jan Kreuzer <kontrollator@gmx.de>
> >> Date		: 2010-06-05 06:15 (4 days old)
> > 
> > This seems to have been introduced by
> > 
> > 	commit 7cbaef9c83e58bbd4bdd534b09052b6c5ec457d5
> > 	Author: Ingo Molnar <mingo@elte.hu>
> > 	Date:   Sat Nov 8 17:05:38 2008 +0100
> > 
> > 	    sched: optimize sched_clock() a bit
> >     
> > 	    sched_clock() uses cycles_2_ns() needlessly - which is an irq-disabling
> > 	    variant of __cycles_2_ns().
> >     
> > 	    Most of the time sched_clock() is called with irqs disabled already.
> > 	    The few places that call it with irqs enabled need to be updated.
> >     
> > 	    Signed-off-by: Ingo Molnar <mingo@elte.hu>
> > 
> > and this seems to be one of those calling cases that need to be updated.
> > 
> > Ingo? The call trace is:
> > 
> > 	BUG: using smp_processor_id() in preemptible [00000000] code: jbd2/sda2-8/337
> > 	caller is native_sched_clock+0x3c/0x68
> > 	Pid: 337, comm: jbd2/sda2-8 Not tainted 2.6.35-rc1jan+ #4
> > 	Call Trace:
> > 	[<ffffffff812362c5>] debug_smp_processor_id+0xc9/0xe4
> > 	[<ffffffff8101059d>] native_sched_clock+0x3c/0x68
> > 	[<ffffffff8101043d>] sched_clock+0x9/0xd
> > 	[<ffffffff81212d7a>] blk_rq_init+0x97/0xa3
> > 	[<ffffffff81214d71>] get_request+0x1c4/0x2d0
> > 	[<ffffffff81214ea6>] get_request_wait+0x29/0x1a6
> > 	[<ffffffff81215537>] __make_request+0x338/0x45b
> > 	[<ffffffff812147c2>] generic_make_request+0x2bb/0x330
> > 	[<ffffffff81214909>] submit_bio+0xd2/0xef
> > 	[<ffffffff811413cb>] submit_bh+0xf4/0x116
> > 	[<ffffffff81144853>] block_write_full_page_endio+0x89/0x96
> > 	[<ffffffff81144875>] block_write_full_page+0x15/0x17
> > 	[<ffffffff8119b00a>] ext4_writepage+0x356/0x36b
> > 	[<ffffffff810e1f91>] __writepage+0x1a/0x39
> > 	[<ffffffff810e32a6>] write_cache_pages+0x20d/0x346
> > 	[<ffffffff810e3406>] generic_writepages+0x27/0x29
> > 	[<ffffffff811ca279>] journal_submit_data_buffers+0x110/0x17d
> > 	[<ffffffff811ca986>] jbd2_journal_commit_transaction+0x4cb/0x156d
> > 	[<ffffffff811d0cba>] kjournald2+0x147/0x37a
> > 
> > (from the bugzilla thing)
> 
> This should be fixed by commit 28f4197e which was merged on friday.

Thanks, closed.

Rafael

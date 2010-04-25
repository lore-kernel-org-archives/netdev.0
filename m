From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] RCU: don't turn off lockdep when find suspicious
 rcu_dereference_check() usage
Date: Sat, 24 Apr 2010 19:36:33 -0700
Message-ID: <20100425023633.GN2440@linux.vnet.ibm.com>
References: <j2ya44ae5cd1004200545q6be4ec82o18ae99d93e8c29c7@mail.gmail.com>
 <20100420135227.GC2628@linux.vnet.ibm.com>
 <t2la44ae5cd1004200838w87256e80v9dcde91342b321db@mail.gmail.com>
 <20100421213543.GO2563@linux.vnet.ibm.com>
 <20100422145640.GB3228@redhat.com>
 <20100422160144.GC2524@linux.vnet.ibm.com>
 <h2xa44ae5cd1004230550uf734c89eo2b1d1945d446068c@mail.gmail.com>
 <20100423194255.GE2589@linux.vnet.ibm.com>
 <m2xa44ae5cd1004231559hcf90671asf146a43b4748c2c3@mail.gmail.com>
 <u2qa44ae5cd1004232235i2e1cd2a0g634fc1d5d8c3f7c2@mail.gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivek Goyal <vgoyal@redhat.com>, Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, nauman@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Jens Axboe <jens.axboe@oracle.com>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Li Zefan <lizf@cn.fujitsu.com>
To: Miles Lane <miles.lane@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <u2qa44ae5cd1004232235i2e1cd2a0g634fc1d5d8c3f7c2@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 24, 2010 at 01:35:01AM -0400, Miles Lane wrote:
> 2.6.34-rc5-git5 with all of your patches applied.
> 
> I reconfigured my kernel build options and got the following new issue:
> 
> [    2.686515] [ INFO: suspicious rcu_dereference_check() usage. ]
> [    2.686519] ---------------------------------------------------
> [    2.686523] kernel/cgroup.c:4438 invoked rcu_dereference_check()
> without protection!
> [    2.686526]
> [    2.686527] other info that might help us debug this:
> [    2.686529]
> [    2.686532]
> [    2.686533] rcu_scheduler_active = 1, debug_locks = 1
> [    2.686537] 2 locks held by swapper/1:
> [    2.686540]  #0:  (mtd_table_mutex){+.+.+.}, at:
> [<ffffffff812d7714>] register_mtd_blktrans+0xa2/0x25e
> [    2.686555]  #1:  (&(&blkcg->lock)->rlock){......}, at:
> [<ffffffff811ca7bd>] blkiocg_add_blkio_group+0x29/0x7f
> [    2.686566]
> [    2.686567] stack backtrace:
> [    2.686572] Pid: 1, comm: swapper Not tainted 2.6.34-rc5-git5 #25
> [    2.686576] Call Trace:
> [    2.686584]  [<ffffffff810642da>] lockdep_rcu_dereference+0x9d/0xa5
> [    2.686591]  [<ffffffff8107af54>] css_id+0x3f/0x52
> [    2.686597]  [<ffffffff811ca7cc>] blkiocg_add_blkio_group+0x38/0x7f
> [    2.686603]  [<ffffffff811cc593>] cfq_init_queue+0xdf/0x2dc
> [    2.686609]  [<ffffffff811bb858>] elevator_init+0xba/0xf5
> [    2.686616]  [<ffffffff812d7046>] ? mtd_blktrans_request+0x0/0x1c
> [    2.686623]  [<ffffffff811c0b62>] blk_init_queue_node+0x12f/0x135
> [    2.686629]  [<ffffffff811c0b74>] blk_init_queue+0xc/0xe
> [    2.686635]  [<ffffffff812d7777>] register_mtd_blktrans+0x105/0x25e
> [    2.686642]  [<ffffffff818c0de9>] ? init_mtdblock+0x0/0x2c
> [    2.686648]  [<ffffffff818c0e13>] init_mtdblock+0x2a/0x2c
> [    2.686656]  [<ffffffff810001ef>] do_one_initcall+0x59/0x14e
> [    2.686663]  [<ffffffff818986a6>] kernel_init+0x160/0x1ea
> [    2.686669]  [<ffffffff81003814>] kernel_thread_helper+0x4/0x10
> [    2.686677]  [<ffffffff8140d77c>] ? restore_args+0x0/0x30
> [    2.686683]  [<ffffffff81898546>] ? kernel_init+0x0/0x1ea
> [    2.686688]  [<ffffffff81003810>] ? kernel_thread_helper+0x0/0x10
> [    2.687683] mtdoops: mtd device (mtddev=name/number) must be supplied

This should be covered by the patch I sent with my previous email.

And thank you again, Miles, for all the testing!!!

							Thanx, Paul

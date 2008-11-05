From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: next-20081103 - possible circular locking dependency detected while bring up eth1
Date: Wed,  5 Nov 2008 18:14:43 +0900 (JST)
Message-ID: <20081105181242.9688.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081105071306.GB10881@linux.vnet.ibm.com> <1225871332.7803.2626.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro@jp.fujitsu.com,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, mel@csn.ul.ie
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1225871332.7803.2626.camel@twins>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > [   31.989072] 2 locks held by events/3/18:
> > [   31.989072]  #0:  (events){--..}, at: [<c04367bf>] run_workqueue+0x80/0x189
> > [   31.989072]  #1:  ((linkwatch_work).work){--..}, at: [<c04367bf>] run_workqueue+0x80/0x189
> > [   31.989072] 
> > [   31.989072] stack backtrace:
> > [   31.989072] Pid: 18, comm: events/3 Not tainted 2.6.28-rc3-next-20081103-autotest #1
> > [   31.989072] Call Trace:
> > [   31.989072]  [<c0445662>] print_circular_bug_tail+0xa4/0xaf
> > [   31.989072]  [<c0445c10>] validate_chain+0x5a3/0xb35
> > [   31.989072]  [<c0446822>] __lock_acquire+0x680/0x70e
> > [   31.989072]  [<c04367bf>] ? run_workqueue+0x80/0x189
> > [   31.989072]  [<c044690d>] lock_acquire+0x5d/0x7a
> > [   31.989072]  [<c05e8ef5>] ? rtnl_lock+0xf/0x11
> > [   31.989072]  [<c0651c04>] mutex_lock_nested+0xdf/0x251
> > [   31.989072]  [<c05e8ef5>] ? rtnl_lock+0xf/0x11
> > [   31.989072]  [<c05e8ef5>] ? rtnl_lock+0xf/0x11
> > [   31.989072]  [<c05e8ef5>] rtnl_lock+0xf/0x11
> > [   31.989072]  [<c05ea07a>] linkwatch_event+0x8/0x27
> > [   31.989072]  [<c04367fd>] run_workqueue+0xbe/0x189
> > [   31.989072]  [<c04367bf>] ? run_workqueue+0x80/0x189
> > [   31.989072]  [<c05ea072>] ? linkwatch_event+0x0/0x27
> > [   31.989072]  [<c043713f>] ? worker_thread+0x0/0xbf
> > [   31.989072]  [<c04371f3>] worker_thread+0xb4/0xbf
> > [   31.989072]  [<c0439765>] ? autoremove_wake_function+0x0/0x33
> > [   31.989072]  [<c04396a6>] kthread+0x3b/0x61
> > [   33.690691] tg3: eth1: Link is up at 100 Mbps, full duplex.
> > [   33.690696] tg3: eth1: Flow control is off for TX and off for RX.
> > [   31.989072]  [<c043966b>] ? kthread+0x0/0x61
> > [   31.989072]  [<c040481b>] kernel_thread_helper+0x7/0x10
> > [   33.762336] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
> > [  OK  ]
> 
> I think we have to go with Kosaki-san's vm workqueue...

Very sorry for my lazyness.
akpm did nak vm workqueue patch.

So I prepare new patch now. (it is under testing now)
I expect I can post it tommorow.

Thanks.

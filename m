From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG] igb : rtnl assert on resume
Date: Sat, 08 Oct 2011 19:51:24 +0200
Message-ID: <1318096284.5276.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39985 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752887Ab1JHRva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2011 13:51:30 -0400
Received: by wyg34 with SMTP id 34so4789466wyg.19
        for <netdev@vger.kernel.org>; Sat, 08 Oct 2011 10:51:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys

Not sure if its a regression (it seems linux-3.0 probably should trigger
same trace) but I caught this on latest net-next when suspend/resume
cycle was done :

[ 5279.891512] RTNL: assertion failed at net/core/dev.c (1665)
[ 5279.891515] Pid: 2785, comm: kworker/u:9 Not tainted 3.1.0-rc9+ #81
[ 5279.891517] Call Trace:
[ 5279.891523]  [<ffffffff814802ec>] netif_set_real_num_tx_queues+0x1ac/0x1c0
[ 5279.891540]  [<ffffffffa00244d1>] igb_init_interrupt_scheme+0x151/0x4b0 [igb]
[ 5279.891546]  [<ffffffffa002984d>] igb_resume+0x9d/0x160 [igb]
[ 5279.891550]  [<ffffffff812e0b91>] pci_legacy_resume+0x41/0x60
[ 5279.891552]  [<ffffffff812e17c0>] pci_pm_resume+0x90/0xd0
[ 5279.891555]  [<ffffffff813896b7>] pm_op+0xe7/0x1c0
[ 5279.891558]  [<ffffffff81389ba7>] device_resume+0xf7/0x1b0
[ 5279.891561]  [<ffffffff8108a520>] ? async_schedule+0x20/0x20
[ 5279.891564]  [<ffffffff81389c81>] async_resume+0x21/0x50
[ 5279.891566]  [<ffffffff8108a59f>] async_run_entry_fn+0x7f/0x180
[ 5279.891569]  [<ffffffff8107ca73>] process_one_work+0x123/0x480
[ 5279.891572]  [<ffffffff8107d638>] ? manage_workers.isra.30+0x1e8/0x230
[ 5279.891574]  [<ffffffff8107d7de>] worker_thread+0x15e/0x360
[ 5279.891576]  [<ffffffff8107d680>] ? manage_workers.isra.30+0x230/0x230
[ 5279.891579]  [<ffffffff8108225c>] kthread+0x8c/0xa0
[ 5279.891583]  [<ffffffff8157fc74>] kernel_thread_helper+0x4/0x10
[ 5279.891586]  [<ffffffff810821d0>] ? flush_kthread_worker+0xa0/0xa0
[ 5279.891588]  [<ffffffff8157fc70>] ? gs_change+0x13/0x13

Thanks

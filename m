From: Eric Wheeler <nevdev@lists.ewheeler.net>
Subject: bna alloc_pages() order 2 failure in bnad.c bnad_rxq_refill_page()
Date: Sat, 27 Sep 2014 16:44:22 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1409271631530.26069@ware.dreamhost.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: rmody@brocade.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from homie.mail.dreamhost.com ([208.97.132.208]:36147 "EHLO
	homiemail-a3.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750736AbaI0Xa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Sep 2014 19:30:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

We're using the 10gbe bna card and sometimes we get pages and pages of 
alloc_pages() failure backtraces like below.  (The maintainer 
rmody@brocade.com does not appear to have an active email at brocade, but 
cc'ing again just in case.)

It looks like bnad_rxq_refill_page() in bnad.c is allocating for the 
receive queue but fails.  We've already tried bumping vm.min_free_kbytes 
and vm.zone_reclaim_mode but it doesn't appear to help.

Suggestions?

Would it be appropriate to convert alloc_pages() to a mempool 
implementation?

-Eric

[135367.300669] swapper/5: page allocation failure: order:2, mode:0x4020
[135367.300903] CPU: 5 PID: 0 Comm: swapper/5 Tainted: GF          O 3.14.18 #1
[135367.301137] Hardware name: Supermicro X9SCL/X9SCM/X9SCL/X9SCM, BIOS 2.0c 10/17/2013
[135367.301557]  0000000000000002 ffff88082fd43a78 ffffffff8159e704 0000000000000010
[135367.301986]  0000000000004020 ffff88082fd43b08 ffffffff8113b17b 0000000200000000
[135367.302417]  0000000000000000 00000000fffffffc 0000000000000004 0000003000000000
[135367.302858] Call Trace:
[135367.303077]  <IRQ> [<ffffffff8159e704>] dump_stack+0x49/0x5d
[135367.303310]  [<ffffffff8113b17b>] warn_alloc_failed+0xeb/0x150
[135367.303536]  [<ffffffff8113e2f0>] __alloc_pages_slowpath+0x4a0/0x7e0
[135367.303769]  [<ffffffff8113e8e2>] __alloc_pages_nodemask+0x2b2/0x2c0
[135367.303996]  [<ffffffff81181232>] alloc_pages_current+0xb2/0x170 
[135367.304226]  [<ffffffffa0239cb4>] bnad_rxq_refill_page+0x154/0x1e0 [bna] <---
[135367.304459]  [<ffffffffa023c282>] bnad_cq_process+0x462/0x840 [bna]
[135367.304921]  [<ffffffffa023c6af>] bnad_napi_poll_rx+0x4f/0xc0 [bna]
[135367.305144]  [<ffffffff814dcf4c>] net_rx_action+0xfc/0x280
[135367.305364]  [<ffffffff8105ba83>] __do_softirq+0xf3/0x2c0
[135367.305589]  [<ffffffff8105bd5d>] irq_exit+0xbd/0xd0
[135367.305811]  [<ffffffff815ae697>] do_IRQ+0x67/0x110
[135367.306036]  [<ffffffff815a39ad>] common_interrupt+0x6d/0x6d
[135367.306261]  <EOI> [<ffffffff81486275>] ? cpuidle_enter_state+0x55/0xd0
[135367.306501]  [<ffffffff8148626b>] ? cpuidle_enter_state+0x4b/0xd0
[135367.306719]  [<ffffffff814863b7>] cpuidle_idle_call+0xc7/0x160
[135367.306938]  [<ffffffff8100d73e>] arch_cpu_idle+0xe/0x30
[135367.307156]  [<ffffffff810b187e>] cpu_idle_loop+0x9e/0x250
[135367.307376]  [<ffffffff810b1aa0>] cpu_startup_entry+0x70/0x80
[135367.307598]  [<ffffffff810350d2>] start_secondary+0xd2/0xe0



--
Eric Wheeler, President           eWheeler, Inc. dba Global Linux Security
888-LINUX26 (888-546-8926)        Fax: 503-716-3878           PO Box 25107
www.GlobalLinuxSecurity.pro       Linux since 1996!     Portland, OR 97298

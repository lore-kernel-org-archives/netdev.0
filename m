From: Tony Lindgren <tony@atomide.com>
Subject: cpsw regression in mainline with "cpsw/netcp: cpts depends on
 posix_timers"
Date: Mon, 24 Apr 2017 09:51:05 -0700
Message-ID: <20170424165104.GC3780@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>,
        Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from muru.com ([72.249.23.125]:45194 "EHLO muru.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S974948AbdDXQvJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 12:51:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Looks like commit 07fef3623407 ("cpsw/netcp: cpts depends on posix_timers")
in mainline started triggering the following oops at least on j5eco-evm.

Adding CONFIG_PTP_1588_CLOCK to .config solves it, but the oops hints
something is wrong with the dependencies.. CONFIG_TI_CPTS defaults to N
and not selecting it causes the oops.

Any ideas what's needed to properly fix this?

Regards,

Tony

8< -------------------------
Unhandled fault: external abort on non-linefetch (0x1008) at 0xf09a3018
pgd = c0004000
[f09a3018] *pgd=ae82c811, *pte=4a103653, *ppte=4a103453
Internal error: : 1008 [#1] SMP ARM
Modules linked in:
CPU: 0 PID: 14 Comm: kworker/0:1 Not tainted 4.11.0-rc8 #418
Hardware name: Generic ti814x (Flattened Device Tree)
Workqueue: rpciod rpc_async_schedule
task: ee8f41c0 task.stack: ee93c000
PC is at cpdma_chan_submit+0x154/0x304
LR is at __dma_page_cpu_to_dev+0x28/0xac
pc : [<c0639664>]    lr : [<c011523c>]    psr: a0000093
sp : ee93d958  ip : ef6f9000  fp : 00000000
r10: eeebee40  r9 : 80000013  r8 : eed956f0
r7 : 00000000  r6 : 0000003c  r5 : f09a3000  r4 : eed956d0
r3 : f09a3018  r2 : aeebb302  r1 : aeebb33e  r0 : ee950410
Flags: NzCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment none
Control: 10c5387d  Table: 80004019  DAC: 00000051
Process kworker/0:1 (pid: 14, stack limit = 0xee93c218)
Stack: (0xee93d958 to 0xee93e000)
d940:                                                       00000001 00000000
d960: ee8f47f0 00000000 eeebee40 eeebee40 eedfc000 eedf4810 00000000 eed956d0
d980: 00000000 eee01800 ee93c000 c063e35c 00000000 c01975d8 eeebee40 eedfc000
d9a0: 00000000 eedfc000 00000000 c06b4c6c 00000000 eee01840 eeebee40 0000002a
d9c0: eedfc000 ee93d9f4 eeeb2e50 eeeb2e00 eeebee40 eee01800 eedfc000 00000000
d9e0: eeeb2e50 00000000 00000008 c06db9f4 eeeb2e00 00000010 00000000 eeeb2e00
da00: 00000000 00000000 00000000 c06b574c eeeb2e50 00000001 c072af98 60000013
da20: 00000000 c072af98 00000878 00000000 00000000 00000000 00000000 eeeb2e80
da40: fffffff4 00000000 ffffe000 eeebee40 c0db2600 c0dbe34a 00000000 c0dbe34a
da60: c06c06bc 00000003 c0dbe34a c072af98 00000000 00000000 c072ae2c 00000000
da80: 3e6fa8c0 426fa8c0 c06c06bc 00000003 c0dbe34a c072b048 3e6fa8c0 eedfc21c
daa0: 00000000 eedfc000 00000000 3e6fa8c0 426fa8c0 c072bdb8 3e6fa8c0 00000000
dac0: eeded088 00000000 00000000 c01b424c c0d59933 c029ed04 ef6db580 c080d190
dae0: eeebdc68 60000013 c06c06a0 00000003 01080020 eeebdc14 eeebef00 eeebdc00
db00: eeebef00 00000001 eeeac000 eeebdc38 eeeac000 00000000 00000000 c06c06bc
db20: eeebdc00 eeebdc14 00000001 c06c4144 ffff8d80 eeebdc00 eeeac000 00000000
db40: c0dbe2e3 c06f3550 eeeac000 00000000 00000000 c06c4f78 c0db6e78 c0d07da0
db60: 00000000 00000000 ee8f41c0 00000006 eeebde10 eeebdc00 eedfc000 426fa8c0
db80: c0dbe2e3 c0db2600 eeeac000 00000000 00000000 c06f3550 00000000 00000000
dba0: c06f32c0 00000000 00000000 00000010 c06f6b6c 60000013 c06f6b44 426fa8c0
dbc0: ffffe000 00000000 eeeac000 c0dbe2e3 c0db2600 00000001 c06f75b0 00000074
dbe0: 00000000 c06f6b6c 00000000 00000000 c06f6a70 00000000 eedfc000 eea36040
dc00: ee93dc54 c06f51b0 ee93ddb8 3e6fa8c0 eea36340 c06f777c ee8f4e30 eeeac000
dc20: c0db2600 c0db2600 eea36040 eeebde24 00000071 ee93dd00 c0725248 3e6fa8c0
dc40: eeeac000 c06f75b0 00000000 ffff0000 ee93dd04 ee93dc54 ee93dc54 eeeac000
dc60: eea36040 eeebde24 00000071 ee93dd00 00000000 3e6fa8c0 eeeac000 c0725248
dc80: eea36040 ee93ddb8 ee93dd00 426fa8c0 00000058 00000060 3e6fa8c0 c0726f3c
dca0: 00000060 00000008 ee93dce4 ee93dce0 00004040 60000013 c07222fc 00000000
dcc0: 00000000 00000058 00000000 c06f51b0 00006f00 c0691c74 c0db2600 ee93de5c
dce0: 00000000 ee8f47f0 c0ee0000 426fa8c0 00000000 00000000 ffff0000 00000004
dd00: 00000002 00000001 00000000 00110000 00000000 00000007 00000000 00000000
dd20: 00000000 ee93de5c 3e6fa8c0 426fa8c0 d5866f00 ee8f41c0 00000001 eeeb100c
dd40: 00000000 c019a0d8 00000001 ffffe000 c0733718 c013e764 eea36040 ee93ddb8
dd60: 00000058 c0733718 eea36040 c0734310 00000000 00000000 00001944 00000000
dd80: ee32a900 00000010 eeeb100c 00000000 eeebb404 ee93de5c c0dc5a04 c0691c74
dda0: 00000000 c07d8460 00000058 00000000 eeeb6804 00000058 eeeb100c 00000010
ddc0: 00000003 00000000 00000000 ee93ddb8 00000000 00000000 00000000 00000000
dde0: 00004040 00000000 00000000 00000001 00000000 eeebb404 ee32a900 00000058
de00: 00000000 c07d84d4 00000000 00000000 c1566b80 00000000 c1566bc4 c01c7b3c
de20: 00000001 eeeb1000 eeebb400 eeeac0c0 eeebb474 eeeb1344 00000000 c0dc5874
de40: c0dc5a04 c07d8a10 00000000 00000001 ee93de5c eeeac0c0 eeebb474 00000000
de60: eeeb1000 eeebb400 eeeac0c0 c07d5240 eeeb685c eeebb404 eeeb6954 eeeac0c0
de80: eeebb400 eeebb400 00000681 fef5f746 c0d0796c c0dc5874 ee93c000 c07d1fe4
dea0: eee4c800 c01975d8 eeeac0c0 ee8ff080 ef6dfa40 c07d1e8c c07d1e8c c07dde98
dec0: 00000000 00000681 00000000 00000000 ffffe000 00000000 60000013 eeeac0e4
dee0: ee8ff080 ef6dfa40 ee93df20 ff7f0c00 c0d0796c c0dc2d54 c0d4fa8e c0154dac
df00: 00000001 00000000 c0154cf4 00000001 00000000 00000000 c0155e80 00000008
df20: c15a3644 c0f151cc 00000000 c0b00010 ee8ff080 ef6dfa40 ee8ff098 00000008
df40: ef6dfa74 ee93c000 c0d04900 ef6dfa40 ee8ff080 c0155e0c 00000000 ee92a700
df60: ffffe000 ee8ff000 00000000 ee92a700 ee93c000 ee8ff080 c0155dd0 ee8ff038
df80: ee891e90 c015bad8 ee93c000 ee92a700 c015b9c8 00000000 00000000 00000000
dfa0: 00000000 00000000 00000000 c01077b0 00000000 00000000 00000000 00000000
dfc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
dfe0: 00000000 00000000 00000000 00000000 00000013 00000000 bde4cdce 6d799827
[<c0639664>] (cpdma_chan_submit) from [<c063e35c>] (cpsw_ndo_start_xmit+0x84/0x178)
[<c063e35c>] (cpsw_ndo_start_xmit) from [<c06b4c6c>] (dev_hard_start_xmit+0xc4/0x3bc)
[<c06b4c6c>] (dev_hard_start_xmit) from [<c06db9f4>] (sch_direct_xmit+0xcc/0x194)
[<c06db9f4>] (sch_direct_xmit) from [<c06b574c>] (__dev_queue_xmit+0x6f4/0x984)
[<c06b574c>] (__dev_queue_xmit) from [<c072af98>] (arp_xmit+0x16c/0x1f0)
[<c072af98>] (arp_xmit) from [<c072bdb8>] (arp_solicit+0x17c/0x44c)
[<c072bdb8>] (arp_solicit) from [<c06c06bc>] (neigh_probe+0x54/0x80)
[<c06c06bc>] (neigh_probe) from [<c06c4144>] (__neigh_event_send+0x224/0x32c)
[<c06c4144>] (__neigh_event_send) from [<c06c4f78>] (neigh_resolve_output+0x16c/0x1e8)
[<c06c4f78>] (neigh_resolve_output) from [<c06f3550>] (ip_finish_output2+0x304/0x754)
[<c06f3550>] (ip_finish_output2) from [<c06f6b6c>] (ip_output+0x1fc/0x328)
[<c06f6b6c>] (ip_output) from [<c06f75b0>] (ip_send_skb+0x1c/0xf0)
[<c06f75b0>] (ip_send_skb) from [<c0725248>] (udp_send_skb+0xe0/0x2bc)
[<c0725248>] (udp_send_skb) from [<c0726f3c>] (udp_sendmsg+0x2b4/0x9c8)
[<c0726f3c>] (udp_sendmsg) from [<c0691c74>] (sock_sendmsg+0x14/0x24)
[<c0691c74>] (sock_sendmsg) from [<c07d8460>] (xs_send_kvec+0x84/0x94)
[<c07d8460>] (xs_send_kvec) from [<c07d84d4>] (xs_sendpages+0x64/0x21c)
[<c07d84d4>] (xs_sendpages) from [<c07d8a10>] (xs_udp_send_request+0x50/0x10c)
[<c07d8a10>] (xs_udp_send_request) from [<c07d5240>] (xprt_transmit+0x4c/0x3ac)
[<c07d5240>] (xprt_transmit) from [<c07d1fe4>] (call_transmit+0x158/0x208)
[<c07d1fe4>] (call_transmit) from [<c07dde98>] (__rpc_execute+0x9c/0x524)
[<c07dde98>] (__rpc_execute) from [<c0154dac>] (process_one_work+0x2b0/0x774)
[<c0154dac>] (process_one_work) from [<c0155e0c>] (worker_thread+0x3c/0x540)
[<c0155e0c>] (worker_thread) from [<c015bad8>] (kthread+0x110/0x150)
[<c015bad8>] (kthread) from [<c01077b0>] (ret_from_fork+0x14/0x24)
Code: e585a010 e5852014 e2853018 e5836000 (e5933000)

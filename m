From: Josip Rodin <joy@entuzijast.net>
Subject: bnx2_poll panicking kernel
Date: Mon, 16 Jun 2008 14:57:35 +0200
Message-ID: <20080616125735.GA5967@orion.carnet.hr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mirrors@debian.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orion.CARNet.hr ([161.53.160.90]:40951 "EHLO orion.carnet.hr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756143AbYFPNiK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 09:38:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Has anyone seen the below bug before? I'm already upgrading in hope that it
might be already fixed in a newer kernel, but anyway.

It started happening a few days ago, on a load of a few tens of MB/s (Debian
rsync mirroring). It doesn't happen on every mirror pulse, so it's not
exactly reproducible...

I'm not sure what the perl process could be. I have one script running
as part of the RRD-graphing setup, it connects to apache's server-status
page every minute.

It certainly doesn't sound like something that should affect the network
driver or the kernel task scheduler...

Unable to handle kernel NULL pointer dereference at 0000000000000
0bc RIP: 
 [<ffffffff88042eee>] :bnx2:bnx2_poll+0xfe/0xd10
PGD 194c69067 PUD 19844c067 PMD 0 
Oops: 0000 [1] SMP 
CPU 4 
Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler nfs lockd nfs_acl sunrpc
 thermal fan button processor ac battery cls_u32 sch_sfq sch_htb ip6t_REJECT ip6
t_LOG ip6table_filter ip6_tables ipt_REJECT xt_tcpudp iptable_filter ip_tables x
_tables ipv6 dm_snapshot dm_mirror dm_mod usbhid ehci_hcd bnx2 zlib_inflate uhci
_hcd crc32 usbcore shpchp
Pid: 5854, comm: perl Not tainted 2.6.22.18 #3
IP: 0010:[<ffffffff88042eee>]  [<ffffffff88042eee>] :bnx2:bnx2_poll+0xfe/0xd10
RSP: 0018:ffff81022fe57e38  EFLAGS: 00010282
RAX: 00000000000096c7 RBX: ffff81022d6209e0 RCX: 00000000000096c6
RDX: 0000000000000080 RSI: 000000000000009e RDI: ffff81007f1dc7d8
RBP: 0000000096c6969e R08: ffff810198cef900 R09: 0000000000000003
R10: 00000000dfdac3ce R11: 0000000000000003 R12: 000000000000009c
R13: 0000000000000001 R14: 0000000000000000 R15: ffff81022fcd6780
FS:  00002b444ada1ae0(0000) GS:ffff81022fe25c40(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000000000bc CR3: 00000002155c0000 CR4: 00000000000006e0
Process perl (pid: 5854, threadinfo ffff81020fe74000, task ffff81011b864e80)
Stack:  000000020e524810 ffff81022f348070 ffff81022d63f000 ffff81022fe57f4c
 ffff81022fcd6000 0000000400000040 ffff810200000001 ffffffff805968d9
 0000005600000004 00000000a576e010 ffffc20000012000 ffff81022d102000
Call Trace:
 <IRQ>  [<ffffffff802291f0>] run_rebalance_domains+0x170/0x460
 [<ffffffff8022802e>] task_running_tick+0x11e/0x320
 [<ffffffff803dcff0>] net_rx_action+0xc0/0x210
 [<ffffffff802373ec>] run_timer_softirq+0x3c/0x1d0
 [<ffffffff80233e09>] __do_softirq+0x69/0xe0
 [<ffffffff8020abbc>] call_softirq+0x1c/0x30
 <EOI>  [<ffffffff8020c975>] do_softirq+0x35/0x90
 [<ffffffff80233c5a>] local_bh_enable+0x5a/0xa0
 [<ffffffff80296e67>] seq_read+0x267/0x2e0
 [<ffffffff8027a5e5>] vfs_read+0xc5/0x160
 [<ffffffff8027aac3>] sys_read+0x53/0x90
 [<ffffffff80209a2e>] system_call+0x7e/0x83


Code: 41 8b 86 bc 00 00 00 49 03 86 c0 00 00 00 66 83 78 06 00 0f 
RIP  [<ffffffff88042eee>] :bnx2:bnx2_poll+0xfe/0xd10
 RSP <ffff81022fe57e38>
CR2: 00000000000000bc
Kernel panic - not syncing: Aiee, killing interrupt handler!

-- 
     2. That which causes joy or happiness.

From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 62171] New: Kernel In local_bh_enable in case of Vlan
 Tagged ICMP Packets
Date: Thu, 26 Sep 2013 14:38:09 -0700
Message-ID: <20130926143809.6b68ac36@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gautam06acharya@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35105 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754035Ab3IZViN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 17:38:13 -0400
Received: by mail-pa0-f51.google.com with SMTP id kp14so1900687pab.10
        for <netdev@vger.kernel.org>; Thu, 26 Sep 2013 14:38:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I suspect this bug is against a kernel which is outside the window of versions
that upstream developers care about, but forwarding it anyway.

The 2.6.27.18 kernel is from Feb 2009!

Begin forwarded message:

Date: Thu, 26 Sep 2013 06:22:51 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 62171] New: Kernel In local_bh_enable in case of Vlan Tagged ICMP Packets


https://bugzilla.kernel.org/show_bug.cgi?id=62171

            Bug ID: 62171
           Summary: Kernel In local_bh_enable in case of Vlan Tagged ICMP
                    Packets
           Product: Networking
           Version: 2.5
    Kernel Version: Linux 2.6.27.18
          Hardware: Mips64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: gautam06acharya@gmail.com
        Regression: No

Hi,

Kernel In based on Linux Version 2.6.27.18, Cavium octeon Board is used. In SMP
mode but one one cpu is loaded with Linux Kernel.

Its getting crashed in WARN_ON_ONCE in _local_bh_enable_ip called from
local_bh_enable.

Please Find Below Stack Trace Regarding this Crash:

[<ffffffff81154108>] warn_on_slowpath+0x58/0x90

[<ffffffff8115bd20>] local_bh_enable+0x88/0xf8

[<ffffffff81344a44>] dev_queue_xmit+0x144/0x688

[<ffffffff81301f04>] bond_dev_queue_xmit+0x44/0x178

[<ffffffff81302408>] bond_xmit_activebackup+0xb0/0xe8

[<ffffffff81344ea4>] dev_queue_xmit+0x5a4/0x688

[<ffffffff813d59b4>] vlan_dev_hwaccel_hard_start_xmit+0x8c/0xa0

[<ffffffff81344ea4>] dev_queue_xmit+0x5a4/0x688

[<ffffffff81377cbc>] ip_push_pending_frames+0x37c/0x4c0

[<ffffffff813a0768>] icmp_reply+0x170/0x290

[<ffffffff813a0a58>] icmp_echo+0x58/0x68

[<ffffffff813a11b4>] icmp_rcv+0x334/0x390

[<ffffffff813721a4>] ip_local_deliver_finish+0x13c/0x2d8

[<ffffffff813718c4>] ip_rcv_finish+0x134/0x510

[<ffffffff81343af4>] netif_receive_skb+0x41c/0x5d8

[<ffffffff81343d58>] process_backlog+0xa8/0x160

[<ffffffff8134186c>] net_rx_action+0x194/0x2e8

[<ffffffff8115b71c>] __do_softirq+0x114/0x288

[<ffffffff8115b910>] do_softirq+0x80/0x98

[<ffffffff8115bb8c>] irq_exit+0x64/0x78

[<ffffffff81100e40>] plat_irq_dispatch+0xd0/0x1d0

[<ffffffff81120c80>] ret_from_irq+0x0/0x4

[<ffffffff81120ea0>] r4k_wait+0x20/0x40

[<ffffffff81123414>] cpu_idle+0x34/0x60

-- 
You are receiving this mail because:
You are the assignee for the bug.

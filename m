From: Ben Greear <greearb@candelatech.com>
Subject: reproducible cxgb kernel panic in FC8 kernel 2.6.23.1-49
Date: Tue, 13 Nov 2007 19:13:14 -0800
Message-ID: <473A67CA.8030007@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:34051 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755039AbXKNDNP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 22:13:15 -0500
Received: from [192.168.100.224] (static-71-121-249-218.sttlwa.dsl-w.verizon.net [71.121.249.218])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id lAE3DEDQ012252
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 19:13:15 -0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This panic happens (almost?) immediately after starting TCP traffic between
the cxgb nic on this system and another.  We also got at least one crash
on a custom/tainted 2.6.20.12 kernel, but it would run for at least
a few minutes at ~1Gbps first.

I think my serial console chomped some of this..but it's very reproducible,
so if you need more info I can make the terminal wider and do it again.

I'm not sure it matters..but the peer NIC (directly connected w/fibre) is
a similar cxgb NIC but with TOE support (the longer, more expensive one).


root@lf1002-155 ~]# BUG: unable to handle kernel NULL pointer dereference at virtual address 00000194
printing eip: f8a80b67 *pde = 7d0ac067
Oops: 0002 [#1] SMP
Modules linked in: arc4 michael_mic 8021q cxgb e1000 macvlan pktgen autofs4 sunrpc ipv6 loop dm_multipath i50d
CPU:    1
EIP:    0060:[<f8a80b67>]    Not tainted VLI
EFLAGS: 00010206   (2.6.23.1-49.fc8 #1)
EIP is at t1_poll+0x2e0/0x64a [cxgb]
eax: fffd7d78   ebx: f6e56e02   ecx: f6e20500   edx: 00000000
esi: f6ed8846   edi: f6f63428   ebp: f6820500   esp: c0789f7c
ds: 007b   es: 007b   fs: 00d8  gs: 0000  ss: 0068
Process swapper (pid: 0, ti=c0789000 task=f7c42c20 task.ti=c211d000)
Stack: ffffffff 00000000 ffffffff c0789fd4 f6e20000 f6e20500 00000000 00000000
        f69f2060 f6f63448 00000040 f6f63428 f6e20500 f6f63400 00000000 00000000
        00000000 f6e20000 c2017714 c2017700 c05bdc74 fffd7d78 0000012c 00000001
Call Trace:
  [<c05bdc74>] net_rx_action+0x9a/0x196
  [<c0431e06>] __do_softirq+0x66/0xd3
  [<c04073d5>] do_softirq+0x6c/0xce
  [<c0444675>] tick_do_update_jiffies64+0x15/0xa8
  [<c044018b>] ktime_get+0xf/0x2b
  [<c045bac7>] handle_edge_irq+0x0/0xfc
  [<c0431cc9>] irq_exit+0x38/0x6b
  [<c04074d6>] do_IRQ+0x9f/0xb9
  [<c043ff60>] hrtimer_start+0xe6/0xf0
  [<c0405b6f>] common_interrupt+0x23/0x28
  [<c04032a1>] mwait_idle_with_hints+0x3b/0x3f
  [<c04032a5>] mwait_idle+0x0/0x13
  [<c040340b>] cpu_idle+0xab/0xcc
  =======================
Code: 68 b3 c7 e9 ef 01 00 00 8b 45 50 83 e8 08 3b 45 54 89 45 50 73 04 0f 0b eb fe 8d 43 08 8b 55 14 89 85 a
EIP: [<f8a80b67>] t1_poll+0x2e0/0x64a [cxgb] SS:ESP 0068:c0789f7c
Kernel panic - not syncing: Fatal exception in interrupt


lspci is below:

[root@lf1002-155 ~]# lspci
00:00.0 Host bridge: Intel Corporation 5000V Chipset Memory Controller Hub (rev b1)
00:02.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express x8 Port 2-3 (rev b1)
00:08.0 System peripheral: Intel Corporation 5000 Series Chipset DMA Engine (rev b1)
00:10.0 Host bridge: Intel Corporation 5000 Series Chipset FSB Registers (rev b1)
00:10.1 Host bridge: Intel Corporation 5000 Series Chipset FSB Registers (rev b1)
00:10.2 Host bridge: Intel Corporation 5000 Series Chipset FSB Registers (rev b1)
00:11.0 Host bridge: Intel Corporation 5000 Series Chipset Reserved Registers (rev b1)
00:13.0 Host bridge: Intel Corporation 5000 Series Chipset Reserved Registers (rev b1)
00:15.0 Host bridge: Intel Corporation 5000 Series Chipset FBD Registers (rev b1)
00:16.0 Host bridge: Intel Corporation 5000 Series Chipset FBD Registers (rev b1)
00:1c.0 PCI bridge: Intel Corporation 631xESB/632xESB/3100 Chipset PCI Express Root Port 1 (rev 09)
00:1d.0 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset UHCI USB Controller #1 (rev 09)
00:1d.1 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset UHCI USB Controller #2 (rev 09)
00:1d.2 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset UHCI USB Controller #3 (rev 09)
00:1d.3 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset UHCI USB Controller #4 (rev 09)
00:1d.7 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset EHCI USB2 Controller (rev 09)
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev d9)
00:1f.0 ISA bridge: Intel Corporation 631xESB/632xESB/3100 Chipset LPC Interface Controller (rev 09)
00:1f.1 IDE interface: Intel Corporation 631xESB/632xESB IDE Controller (rev 09)
00:1f.2 IDE interface: Intel Corporation 631xESB/632xESB/3100 Chipset SATA IDE Controller (rev 09)
00:1f.3 SMBus: Intel Corporation 631xESB/632xESB/3100 Chipset SMBus Controller (rev 09)
01:00.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express Upstream Port (rev 01)
01:00.3 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express to PCI-X Bridge (rev 01)
02:00.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express Downstream Port E1 (rev 01)
02:02.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express Downstream Port E3 (rev 01)
04:00.0 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit Ethernet Controller (Copper) (rev 01)
04:00.1 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit Ethernet Controller (Copper) (rev 01)
05:01.0 Ethernet controller: Chelsio Communications Inc Unknown device 000a 07:01.0 VGA compatible controller: ATI Technologies Inc ES1000 (rev 02)
[root@lf1002-155 ~]#



-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


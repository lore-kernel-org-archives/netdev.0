From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: kernel panic, 2.6.38.2, gretap
Date: Thu, 14 Apr 2011 01:58:24 +0300
Message-ID: <3dfb4abac84b3e0147fa25a5e3a9563e@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rev-153-13.globalproof.net ([194.146.153.13]:54122 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S932694Ab1DMXGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 19:06:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Did following rule to route incoming (over eth0) traffic over gretap 
 interface

 Bringing up interface
 ip link add eoip1 type gretap remote X.X.X.X local Y.Y.Y.Y nopmtudisc
 ifconfig eoip1 10.255.254.1 netmask 255.255.255.252 up mtu 1500

 made source routing:
 32000:  from all iif eth0 lookup 203

 Some routes added to table 203

 After few(1-3) seconds running around 30-40 Mbps getting kernel panic:

 Notes: I have vlan on same interface, eth0.2023, where rest of traffic 
 going, and this vlan "shaped" by HTB. It is not involved in gretap 
 operation.
 on eth0 i have huge bfifo:
 qdisc bfifo 8001: dev eth0 root refcnt 9 limit 100000000b
  Sent 14652829681 bytes 15646355 pkt (dropped 0, overlimits 0 requeues 
 8)
  backlog 0b 0p requeues 8


 [  658.492347] skb_over_panic: text:f80f37d4 len:3028 put:1514 
 head:d1af2000 data:d1af20a4 tail:0xd1af2c78 end:0xd1af2700 dev:eth0.2022
 [  658.492975] ------------[ cut here ]------------
 [  658.493264] Kernel BUG at c0377eaf [verbose debug info unavailable]
 [  658.493317] invalid opcode: 0000 [#1]
 SMP

 [  658.493317] last sysfs file: 
 /sys/devices/virtual/net/eth0.2022/address
 [  658.493317] Modules linked in:
 ip_gre
 gre
 netconsole
 ipmi_si
 tun
 configfs
 cls_u32
 sch_htb
 8021q
 garp
 stp
 llc
 iptable_filter
 ipt_addrtype
 xt_dscp
 xt_string
 xt_owner
 xt_multiport
 xt_iprange
 xt_hashlimit
 xt_conntrack
 xt_DSCP
 xt_NFQUEUE
 xt_mark
 xt_connmark
 nf_conntrack
 ip_tables
 x_tables
 bnx2
 ipmi_devintf
 ipmi_msghandler
 processor
 ata_piix
 i5k_amb
 iTCO_wdt
 pata_acpi
 hwmon
 [last unloaded: netconsole]

 [  658.493317]
 [  658.493317] Pid: 0, comm: kworker/0:1 Not tainted 2.6.38.2-devel2 #2

 Dell Inc. PowerEdge 1950
 /
 0D8635

 [  658.493317] EIP: 0060:[<c0377eaf>] EFLAGS: 00010282 CPU: 3
 [  658.493317] EIP is at skb_put+0x7f/0x89
 [  658.493317] EAX: 0000008e EBX: d1af2c78 ECX: f64b5e40 EDX: c05032e8
 [  658.493317] ESI: 000005ea EDI: f5f28380 EBP: 006d006d ESP: f64b5e3c
 [  658.493317]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
 [  658.493317] Process kworker/0:1 (pid: 0, ti=f64b4000 task=f64a4a80 
 task.ti=f64b0000)
 [  658.493317] Stack:
 [  658.493317]  c05032e8
 f80f37d4
 00000bd4
 000005ea
 d1af2000
 d1af20a4
 d1af2c78
 d1af2700

 [  658.493317]  f5e54000
 00000000
 eee81e00
 f80f37d4
 00000604
 00000002
 00000000
 e5602500

 [  658.493317]  00000001
 f6b02cb8
 0000004d
 512e75c0
 eef28480
 00000000
 f5f28400
 f5f28380

 [  658.493317] Call Trace:
 [  658.493317]  [<f80f37d4>] ? bnx2_poll_work+0x980/0xf48 [bnx2]
 [  658.493317]  [<f80f37d4>] ? bnx2_poll_work+0x980/0xf48 [bnx2]
 [  658.493317]  [<c0140e49>] ? hrtimer_start+0x20/0x25
 [  658.493317]  [<f826ffd1>] ? htb_dequeue+0x757/0x770 [sch_htb]
 [  658.493317]  [<f80f3f27>] ? bnx2_poll+0xf7/0x1d9 [bnx2]
 [  658.493317]  [<c037f564>] ? net_rx_action+0x8c/0x176
 [  658.493317]  [<c012f28f>] ? __do_softirq+0x6b/0x104
 [  658.493317]  [<c012f224>] ? __do_softirq+0x0/0x104
 [  658.493317]  <IRQ>

 [  658.493317]  [<c012f17e>] ? irq_exit+0x26/0x59
 [  658.493317]  [<c0103b3d>] ? do_IRQ+0x81/0x95
 [  658.493317]  [<c0102ca9>] ? common_interrupt+0x29/0x30
 [  658.493317]  [<c010807a>] ? mwait_idle+0x51/0x56
 [  658.493317]  [<c0101a97>] ? cpu_idle+0x41/0x5e
 [  658.493317] Code:
 24
 14
 8b
 81
 a4
 00
 00
 00
 89
 74
 24
 0c
 89
 44
 24
 10
 8b
 41
 4c
 c7
 04
 24
 e8
 32
 50
 c0
 89
 44
 24
 08
 8b
 44
 24
 2c
 89
 44
 24
 04
 e8
 51
 85
 07
 00
 Apr 13 22:48:46 217.151.224.119 unparseable log message: "<0f> "
 0b
 eb
 fe
 83
 c4
 24
 5b
 5e
 c3
 55
 57
 56
 53
 83
 ec
 24
 fc
 89
 c5
 89

 [  658.493317] EIP: [<c0377eaf>]
 skb_put+0x7f/0x89
 SS:ESP 0068:f64b5e3c
 [  658.512472] ---[ end trace d06a076521439891 ]---
 [  658.512750] Kernel panic - not syncing: Fatal exception in interrupt
 [  658.514034] Rebooting in 5 seconds..



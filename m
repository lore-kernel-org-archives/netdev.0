From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: e1000e, kernel 3.12.3, packetloss and periodic Detected Hardware
 Unit Hang
Date: Sat, 07 Dec 2013 08:32:15 +0200
Message-ID: <1c03e797a32cfe05a6269e8f219e2f62@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:54180 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833Ab3LGGiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Dec 2013 01:38:04 -0500
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id 96A0A486F42
	for <netdev@vger.kernel.org>; Sat,  7 Dec 2013 08:32:17 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On one of clients got new hardware and i started to get periodic 
watchdog/hang messages in dmesg and packetloss on e1000e driver, while 
load on device is relatively low.

Here is lspci, ifconfig, ethtool and dmesg information


00:19.0 Ethernet controller: Intel Corporation Device 1503 (rev 04)
         Subsystem: Intel Corporation Device 2031
         Flags: bus master, fast devsel, latency 0, IRQ 43
         Memory at f7c00000 (32-bit, non-prefetchable) [size=128K]
         Memory at f7c35000 (32-bit, non-prefetchable) [size=4K]
         I/O ports at f080 [size=32]
         Capabilities: [c8] Power Management version 2
         Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
         Capabilities: [e0] PCI Advanced Features
         Kernel driver in use: e1000e

BALANCER-WORLDNET ~ # ethtool -i eth0
driver: e1000e
version: 2.3.2-k
firmware-version: 0.13-5
bus-info: 0000:00:19.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no

BALANCER-WORLDNET ~ # ethtool -S eth0
NIC statistics:
      rx_packets: 1500180288
      tx_packets: 1555842579
      rx_bytes: 1154556141222
      tx_bytes: 1139141840890
      rx_broadcast: 168035
      tx_broadcast: 74
      rx_multicast: 40
      tx_multicast: 0
      rx_errors: 0
      tx_errors: 0
      tx_dropped: 0
      multicast: 40
      collisions: 0
      rx_length_errors: 0
      rx_over_errors: 0
      rx_crc_errors: 0
      rx_frame_errors: 0
      rx_no_buffer_count: 0
      rx_missed_errors: 56073
      tx_aborted_errors: 0
      tx_carrier_errors: 0
      tx_fifo_errors: 0
      tx_heartbeat_errors: 0
      tx_window_errors: 0
      tx_abort_late_coll: 0
      tx_deferred_ok: 0
      tx_single_coll_ok: 0
      tx_multi_coll_ok: 0
      tx_timeout_count: 4
      tx_restart_queue: 5
      rx_long_length_errors: 0
      rx_short_length_errors: 0
      rx_align_errors: 0
      tx_tcp_seg_good: 195863453
      tx_tcp_seg_failed: 0
      rx_flow_control_xon: 0
      rx_flow_control_xoff: 0
      tx_flow_control_xon: 0
      tx_flow_control_xoff: 0
      rx_csum_offload_good: 1500000575
      rx_csum_offload_errors: 1104
      rx_header_split: 0
      alloc_rx_buff_failed: 0
      tx_smbus: 0
      rx_smbus: 0
      dropped_smbus: 0
      rx_dma_failed: 0
      tx_dma_failed: 0
      rx_hwtstamp_cleared: 0
      uncorr_ecc_errors: 0
      corr_ecc_errors: 0

BALANCER-WORLDNET ~ # ethtool -d eth0
MAC Registers
-------------
0x00000: CTRL (Device control register)  0x40100240
       Endian mode (buffers):             little
       Link reset:                        normal
       Set link up:                       1
       Invert Loss-Of-Signal:             no
       Receive flow control:              disabled
       Transmit flow control:             disabled
       VLAN mode:                         enabled
       Auto speed detect:                 disabled
       Speed select:                      1000Mb/s
       Force speed:                       no
       Force duplex:                      no
0x00008: STATUS (Device status register) 0x40080083
       Duplex:                            full
       Link up:                           link config
       TBI mode:                          disabled
       Link speed:                        1000Mb/s
       Bus type:                          PCI
       Bus speed:                         33MHz
       Bus width:                         32-bit
0x00100: RCTL (Receive control register) 0x04008002
       Receiver:                          enabled
       Store bad packets:                 disabled
       Unicast promiscuous:               disabled
       Multicast promiscuous:             disabled
       Long packet:                       disabled
       Descriptor minimum threshold size: 1/2
       Broadcast accept mode:             accept
       VLAN filter:                       disabled
       Canonical form indicator:          disabled
       Discard pause frames:              filtered
       Pass MAC control frames:           don't pass
       Receive buffer size:               2048
0x02808: RDLEN (Receive desc length)     0x00001000
0x02810: RDH   (Receive desc head)       0x000000E1
0x02818: RDT   (Receive desc tail)       0x000000D0
0x02820: RDTR  (Receive delay timer)     0x00000000
0x00400: TCTL (Transmit ctrl register)   0x3003F0FA
       Transmitter:                       enabled
       Pad short packets:                 enabled
       Software XOFF Transmission:        disabled
       Re-transmit on late collision:     disabled
0x03808: TDLEN (Transmit desc length)    0x00001000
0x03810: TDH   (Transmit desc head)      0x00000036
0x03818: TDT   (Transmit desc tail)      0x00000036
0x03820: TIDV  (Transmit delay timer)    0x00000008
PHY type:                                unknown


BALANCER-WORLDNET ~ # ethtool eth0
Settings for eth0:
         Supported ports: [ TP ]
         Supported link modes:   10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Full
         Supported pause frame use: No
         Supports auto-negotiation: Yes
         Advertised link modes:  10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Full
         Advertised pause frame use: No
         Advertised auto-negotiation: Yes
         Speed: 1000Mb/s
         Duplex: Full
         Port: Twisted Pair
         PHYAD: 2
         Transceiver: internal
         Auto-negotiation: on
         MDI-X: off (auto)
         Supports Wake-on: pumbg
         Wake-on: g
         Current message level: 0x00000007 (7)
                                drv probe link
         Link detected: yes




BALANCER-WORLDNET ~ # ethtool -e eth0
Offset          Values
------          ------
0x0000:         00 1e 8c f4 5a e6 00 08 ff ff d5 00 ff ff ff ff
0x0010:         ff ff ff ff c3 10 31 20 86 80 03 15 00 00 00 00
0x0020:         02 07 00 00 00 00 05 a5 28 30 00 1a 00 00 00 0c
0x0030:         f4 18 40 0b 43 08 13 01 02 15 ad ba 02 15 03 15
0x0040:         ad ba ad ba ad ba 02 15 00 80 90 80 00 4e 86 08
0x0050:         00 00 00 00 07 00 00 00 00 00 00 00 00 00 ff ff
0x0060:         00 01 00 40 51 13 07 40 ff ff ff ff ff ff ff ff
0x0070:         ff ff ff ff ff ff ff ff ff ff 00 01 ff ff a7 97
0x0080:         00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0x0090:         00 00 00 00 00 00 ff ff ff ff ff ff ff ff ff ff
0x00a0:         02 34 30 00 14 02 31 00 36 38 30 00 0f 00 31 00
0x00b0:         37 38 30 00 0a 00 31 00 38 38 30 00 10 00 31 00
0x00c0:         3a 38 30 00 03 00 31 00 ae 38 30 00 18 00 31 00
0x00d0:         af 38 30 00 18 00 31 00 b0 38 30 00 18 00 31 00
0x00e0:         1a 84 32 00 4c 52 3a 00 00 00 32 00 40 60 1f 00
0x00f0:         04 d1 11 00 80 60 1f 00 00 cc 10 00 80 08 15 00
0x0100:         d5 35 13 00 00 00 1f 00 ff ff ff ff ff ff ff ff
0x0110:         ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
(rest are mostly ff and 00 values)

eth0      Link encap:Ethernet  HWaddr 00:1E:8C:F4:5A:E6
           inet addr:10.0.254.6  Bcast:10.0.254.31  Mask:255.255.255.224
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:1492876627 errors:0 dropped:110395 overruns:0 
frame:0
           TX packets:1549628201 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:1148839270774 (1.0 TiB)  TX bytes:1133594933258 (1.0 
TiB)
           Interrupt:20 Memory:f7c00000-f7c20000


[17929.990868] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
[17929.990868]   TDH                  <78>
[17929.990868]   TDT                  <24>
[17929.990868]   next_to_use          <24>
[17929.990868]   next_to_clean        <76>
[17929.990868] buffer_info[next_to_clean]:
[17929.990868]   time_stamp           <1010cde6a>
[17929.990868]   next_to_watch        <78>
[17929.990868]   jiffies              <1010ce2cc>
[17929.990868]   next_to_watch.status <0>
[17929.990868] MAC Status             <40080083>
[17929.990868] PHY Status             <796d>
[17929.990868] PHY 1000BASE-T Status  <3800>
[17929.990868] PHY Extended Status    <3000>
[17929.990868] PCI Status             <10>
[17931.991763] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
[17931.991763]   TDH                  <78>
[17931.991763]   TDT                  <24>
[17931.991763]   next_to_use          <24>
[17931.991763]   next_to_clean        <76>
[17931.991763] buffer_info[next_to_clean]:
[17931.991763]   time_stamp           <1010cde6a>
[17931.991763]   next_to_watch        <78>
[17931.991763]   jiffies              <1010cea9c>
[17931.991763]   next_to_watch.status <0>
[17931.991763] MAC Status             <40080083>
[17931.991763] PHY Status             <796d>
[17931.991763] PHY 1000BASE-T Status  <3800>
[17931.991763] PHY Extended Status    <3000>
[17931.991763] PCI Status             <10>
[17933.992670] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
[17933.992670]   TDH                  <78>
[17933.992670]   TDT                  <24>
[17933.992670]   next_to_use          <24>
[17933.992670]   next_to_clean        <76>
[17933.992670] buffer_info[next_to_clean]:
[17933.992670]   time_stamp           <1010cde6a>
[17933.992670]   next_to_watch        <78>
[17933.992670]   jiffies              <1010cf26c>
[17933.992670]   next_to_watch.status <0>
[17933.992670] MAC Status             <40080083>
[17933.992670] PHY Status             <796d>
[17933.992670] PHY 1000BASE-T Status  <3800>
[17933.992670] PHY Extended Status    <3000>
[17933.992670] PCI Status             <10>
[17933.995923] ------------[ cut here ]------------
[17933.996003] WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:264 
dev_watchdog+0x14d/0x1fd()
[17933.996122] NETDEV WATCHDOG: eth0 (e1000e): transmit queue 0 timed 
out
[17933.996185] Modules linked in: xt_tcpudp xt_mark iptable_mangle 
ip_tables x_tables 8021q garp stp mrp llc
[17933.997772] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 
3.12.3-build-0006 #6
[17933.997837] Hardware name:                  /DH77KC, BIOS 
KCH7710H.86A.0069.2012.0224.1825 02/24/2012
[17933.997957]  0000000000000009 ffff88031f203d80 ffffffff8151971a 
0000000000000007
[17933.998078]  ffff88031f203dd0 ffff88031f203dc0 ffffffff810356df 
ffffffff81059db4
[17933.998197]  ffffffff814bcdb7 ffff880310768000 ffff880310339000 
0000000000000001
[17933.998316] Call Trace:
[17933.998374]  <IRQ>  [<ffffffff8151971a>] dump_stack+0x46/0x58
[17933.998447]  [<ffffffff810356df>] warn_slowpath_common+0x77/0x91
[17933.998513]  [<ffffffff81059db4>] ? update_curr+0x5a/0xa8
[17933.998576]  [<ffffffff814bcdb7>] ? dev_watchdog+0x14d/0x1fd
[17933.998640]  [<ffffffff8103578d>] warn_slowpath_fmt+0x41/0x43
[17933.998705]  [<ffffffff814bcdb7>] dev_watchdog+0x14d/0x1fd
[17933.998769]  [<ffffffff814bcc6a>] ? 
psched_ratecfg_precompute+0x61/0x61
[17933.998835]  [<ffffffff8103e1b6>] call_timer_fn.isra.27+0x25/0x7f
[17933.998905]  [<ffffffff8103e357>] run_timer_softirq+0x147/0x183
[17933.998969]  [<ffffffff810390bf>] __do_softirq+0xb7/0x16d
[17933.999034]  [<ffffffff81520abc>] call_softirq+0x1c/0x30
[17933.999100]  [<ffffffff81004392>] do_softirq+0x32/0x68
[17933.999162]  [<ffffffff81039248>] irq_exit+0x3e/0x83
[17933.999227]  [<ffffffff81025270>] smp_apic_timer_interrupt+0x40/0x4d
[17933.999292]  [<ffffffff81520447>] apic_timer_interrupt+0x67/0x70
[17933.999354]  <EOI>  [<ffffffff81479426>] ? 
cpuidle_enter_state+0x49/0xac
[17933.999427]  [<ffffffff8147941f>] ? cpuidle_enter_state+0x42/0xac
[17933.999491]  [<ffffffff8147954c>] cpuidle_idle_call+0xc3/0x10f
[17933.999557]  [<ffffffff8100a0d6>] arch_cpu_idle+0x9/0x18
[17933.999621]  [<ffffffff81064e92>] cpu_startup_entry+0xf6/0x154
[17933.999685]  [<ffffffff81513d1e>] rest_init+0x72/0x74
[17933.999750]  [<ffffffff818f1c74>] start_kernel+0x38f/0x39c
[17933.999814]  [<ffffffff818f16ed>] ? repair_env_string+0x5a/0x5a
[17933.999879]  [<ffffffff818f143e>] x86_64_start_reservations+0x2a/0x2c
[17933.999950]  [<ffffffff818f14f1>] x86_64_start_kernel+0xb1/0xb5
[17934.000013] ---[ end trace 768f97ac33fb6771 ]---
[17934.000089] e1000e 0000:00:19.0 eth0: Reset adapter unexpectedly
[17937.928779] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow 
Control: None
[40172.244444] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
[40172.244444]   TDH                  <27>
[40172.244444]   TDT                  <12>
[40172.244444]   next_to_use          <12>
[40172.244444]   next_to_clean        <25>
[40172.244444] buffer_info[next_to_clean]:
[40172.244444]   time_stamp           <10260192d>
[40172.244444]   next_to_watch        <27>
[40172.244444]   jiffies              <102601e8c>
[40172.244444]   next_to_watch.status <0>
[40172.244444] MAC Status             <40080083>
[40172.244444] PHY Status             <796d>
[40172.244444] PHY 1000BASE-T Status  <3800>
[40172.244444] PHY Extended Status    <3000>
[40172.244444] PCI Status             <10>
[40174.245374] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
[40174.245374]   TDH                  <27>
[40174.245374]   TDT                  <12>
[40174.245374]   next_to_use          <12>
[40174.245374]   next_to_clean        <25>
[40174.245374] buffer_info[next_to_clean]:
[40174.245374]   time_stamp           <10260192d>
[40174.245374]   next_to_watch        <27>
[40174.245374]   jiffies              <10260265c>
[40174.245374]   next_to_watch.status <0>
[40174.245374] MAC Status             <40080083>
[40174.245374] PHY Status             <796d>
[40174.245374] PHY 1000BASE-T Status  <3800>
[40174.245374] PHY Extended Status    <3000>
[40174.245374] PCI Status             <10>
[40176.246288] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
[40176.246288]   TDH                  <27>
[40176.246288]   TDT                  <12>
[40176.246288]   next_to_use          <12>
[40176.246288]   next_to_clean        <25>
[40176.246288] buffer_info[next_to_clean]:
[40176.246288]   time_stamp           <10260192d>
[40176.246288]   next_to_watch        <27>
[40176.246288]   jiffies              <102602e2c>
[40176.246288]   next_to_watch.status <0>
[40176.246288] MAC Status             <40080083>
[40176.246288] PHY Status             <796d>
[40176.246288] PHY 1000BASE-T Status  <3800>
[40176.246288] PHY Extended Status    <3000>
[40176.246288] PCI Status             <10>
[40178.247156] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
[40178.247156]   TDH                  <27>
[40178.247156]   TDT                  <12>
[40178.247156]   next_to_use          <12>
[40178.247156]   next_to_clean        <25>
[40178.247156] buffer_info[next_to_clean]:
[40178.247156]   time_stamp           <10260192d>
[40178.247156]   next_to_watch        <27>
[40178.247156]   jiffies              <1026035fc>
[40178.247156]   next_to_watch.status <0>
[40178.247156] MAC Status             <40080083>
[40178.247156] PHY Status             <796d>
[40178.247156] PHY 1000BASE-T Status  <3800>
[40178.247156] PHY Extended Status    <3000>
[40178.247156] PCI Status             <10>
[40178.250476] e1000e 0000:00:19.0 eth0: Reset adapter unexpectedly
[40182.163300] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow 
Control: None
[46621.217377] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
[46621.217377]   TDH                  <67>
[46621.217377]   TDT                  <b4>
[46621.217377]   next_to_use          <b4>
[46621.217377]   next_to_clean        <66>
[46621.217377] buffer_info[next_to_clean]:
[46621.217377]   time_stamp           <102c2716b>
[46621.217377]   next_to_watch        <67>
[46621.217377]   jiffies              <102c27a3c>
[46621.217377]   next_to_watch.status <0>
[46621.217377] MAC Status             <40080083>
[46621.217377] PHY Status             <796d>
[46621.217377] PHY 1000BASE-T Status  <3800>
[46621.217377] PHY Extended Status    <3000>
[46621.217377] PCI Status             <10>
[46623.218258] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
[46623.218258]   TDH                  <67>
[46623.218258]   TDT                  <b4>
[46623.218258]   next_to_use          <b4>
[46623.218258]   next_to_clean        <66>
[46623.218258] buffer_info[next_to_clean]:
[46623.218258]   time_stamp           <102c2716b>
[46623.218258]   next_to_watch        <67>
[46623.218258]   jiffies              <102c2820c>
[46623.218258]   next_to_watch.status <0>
[46623.218258] MAC Status             <40080083>
[46623.218258] PHY Status             <796d>
[46623.218258] PHY 1000BASE-T Status  <3800>
[46623.218258] PHY Extended Status    <3000>
[46623.218258] PCI Status             <10>
[46625.219248] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
[46625.219248]   TDH                  <67>
[46625.219248]   TDT                  <b4>
[46625.219248]   next_to_use          <b4>
[46625.219248]   next_to_clean        <66>
[46625.219248] buffer_info[next_to_clean]:
[46625.219248]   time_stamp           <102c2716b>
[46625.219248]   next_to_watch        <67>
[46625.219248]   jiffies              <102c289dc>
[46625.219248]   next_to_watch.status <0>
[46625.219248] MAC Status             <40080083>
[46625.219248] PHY Status             <796d>
[46625.219248] PHY 1000BASE-T Status  <3800>
[46625.219248] PHY Extended Status    <3000>
[46625.219248] PCI Status             <10>
[46625.222534] e1000e 0000:00:19.0 eth0: Reset adapter unexpectedly
[46629.154379] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow 
Control: None
[59201.016664] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
[59201.016664]   TDH                  <ba>
[59201.016664]   TDT                  <a5>
[59201.016664]   next_to_use          <a5>
[59201.016664]   next_to_clean        <b8>
[59201.016664] buffer_info[next_to_clean]:
[59201.016664]   time_stamp           <103824c6c>
[59201.016664]   next_to_watch        <ba>
[59201.016664]   jiffies              <10382576c>
[59201.016664]   next_to_watch.status <0>
[59201.016664] MAC Status             <40080083>
[59201.016664] PHY Status             <796d>
[59201.016664] PHY 1000BASE-T Status  <3800>
[59201.016664] PHY Extended Status    <3000>
[59201.016664] PCI Status             <10>
[59203.017583] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
[59203.017583]   TDH                  <ba>
[59203.017583]   TDT                  <a5>
[59203.017583]   next_to_use          <a5>
[59203.017583]   next_to_clean        <b8>
[59203.017583] buffer_info[next_to_clean]:
[59203.017583]   time_stamp           <103824c6c>
[59203.017583]   next_to_watch        <ba>
[59203.017583]   jiffies              <103825f3c>
[59203.017583]   next_to_watch.status <0>
[59203.017583] MAC Status             <40080083>
[59203.017583] PHY Status             <796d>
[59203.017583] PHY 1000BASE-T Status  <3800>
[59203.017583] PHY Extended Status    <3000>
[59203.017583] PCI Status             <10>
[59205.018454] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
[59205.018454]   TDH                  <ba>
[59205.018454]   TDT                  <a5>
[59205.018454]   next_to_use          <a5>
[59205.018454]   next_to_clean        <b8>
[59205.018454] buffer_info[next_to_clean]:
[59205.018454]   time_stamp           <103824c6c>
[59205.018454]   next_to_watch        <ba>
[59205.018454]   jiffies              <10382670c>
[59205.018454]   next_to_watch.status <0>
[59205.018454] MAC Status             <40080083>
[59205.018454] PHY Status             <796d>
[59205.018454] PHY 1000BASE-T Status  <3800>
[59205.018454] PHY Extended Status    <3000>
[59205.018454] PCI Status             <10>
[59205.021788] e1000e 0000:00:19.0 eth0: Reset adapter unexpectedly
[59208.789543] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow 
Control: None

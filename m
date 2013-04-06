From: Sami Farin <hvtaifwkbgefbaei@gmail.com>
Subject: 3.9.0-rc5-ge24b0bfa: e1000e transmit queue 0 timed out
Date: Sat, 6 Apr 2013 23:39:48 +0300
Message-ID: <20130406203948.dv7ef4xrc3ylt24p@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux Networking Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw03.mail.saunalahti.fi ([195.197.172.111]:51080 "EHLO
	gw03.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932701Ab3DFUuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Apr 2013 16:50:03 -0400
Received: from safari.iki.fi (85-156-14-129.elisa-mobile.fi [85.156.14.129])
	by gw03.mail.saunalahti.fi (Postfix) with ESMTP id C796921667D
	for <netdev@vger.kernel.org>; Sat,  6 Apr 2013 23:39:48 +0300 (EEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

3.8.0-rc4-g5da1f worked OK for 70 days.
Actually, this is the first bug I see with e1000e.
It crashed when I sent a bunch of DNS packets out.

[94334.691772] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x23c/0x245()
[94334.691775] Hardware name: System Product Name
[94334.691777] NETDEV WATCHDOG: eth0 (e1000e): transmit queue 0 timed out
[94334.691779] Modules linked in: nls_iso8859_1 nls_cp437 fuse xt_CLASSIFY ipt_ECN xt_length xt_connmark xt_connlimit ip_set_hash_net xt_set xt_multiport snd_usb_audio snd_usbmidi_lib snd_hwdep snd_rawmidi arptable_filter arp_tables ip6t_rt nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT xt_limit xt_LOG xt_hashlimit xt_owner nf_conntrack_ipv4 nf_defrag_ipv4 xt_tcpudp xt_conntrack ip6table_filter ip6table_mangle ip6_tables iptable_filter iptable_mangle iptable_raw ip_tables bridge stp llc tcp_yeah tcp_westwood tcp_veno tcp_vegas tcp_scalable tcp_lp tcp_illinois tcp_hybla tcp_htcp tcp_highspeed ip_set sch_netem sch_hfsc sch_htb sch_sfq cls_fw cls_u32 cls_route sch_ingress sch_red sch_tbf sch_teql sch_prio sch_fq_codel sch_codel sch_gred sch_qfq cls_rsvp cls_rsvp6 cls_tcindex snd_hda_intel sch_cb
 q sch_dsmark
[94334.691836]  nf_conntrack_netlink nfnetlink hfsplus usbnet mii usbmon at24 at25 uvcvideo videobuf2_vmalloc videobuf2_memops videobuf2_core videodev pps_ldisc pl2303 af_key xfrm4_tunnel esp4 ah4 ipcomp xfrm_ipcomp ipip udf vfat fat oprofile nf_conntrack x_tables dccp_diag dccp cmtp kernelcapi loop ppdev parport_pc lp parport i2c_dev ppp_async ppp_generic slhc ftdi_sio usbserial tun rfcomm bnep w83627ehf hwmon_vid coretemp snd_hda_codec_hdmi snd_hda_codec_realtek hwmon e1000e snd_hda_codec acpi_cpufreq snd_seq snd_seq_device btusb mperf freq_table snd_pcm iTCO_wdt iTCO_vendor_support ptp snd_page_alloc pps_core snd_timer rtc_cmos bluetooth snd soundcore rfkill mei i2c_i801 lpc_ich mxm_wmi wmi kvm binfmt_misc tcp_cubic ecryptfs autofs4 i915 drm_kms_helper video button [last unloaded: pcspk
 r]
[94334.691890] Pid: 0, comm: swapper/2 Not tainted 3.9.0-rc5-ge24b0bfa+ #66
[94334.691891] Call Trace:
[94334.691892]  <IRQ>  [<ffffffff81061083>] warn_slowpath_common+0x6b/0x98
[94334.691898]  [<ffffffff810610f7>] warn_slowpath_fmt+0x47/0x49
[94334.691901]  [<ffffffff8163a9e3>] dev_watchdog+0x23c/0x245
[94334.691903]  [<ffffffff8163a7a7>] ? dev_graft_qdisc+0x6c/0x6c
[94334.691905]  [<ffffffff8106f2d6>] call_timer_fn+0x8a/0x16d
[94334.691907]  [<ffffffff8106f2a6>] ? call_timer_fn+0x5a/0x16d
[94334.691909]  [<ffffffff8163a7a7>] ? dev_graft_qdisc+0x6c/0x6c
[94334.691911]  [<ffffffff8106fbfc>] run_timer_softirq+0x1b6/0x28b
[94334.691913]  [<ffffffff81068943>] __do_softirq+0xdc/0x219
[94334.691915]  [<ffffffff81068b86>] irq_exit+0x5c/0x67
[94334.691917]  [<ffffffff81021e69>] smp_apic_timer_interrupt+0x69/0x97
[94334.691920]  [<ffffffff817294ca>] apic_timer_interrupt+0x6a/0x70
[94334.691921]  <EOI>  [<ffffffff81009b01>] ? default_idle+0x47/0xe5
[94334.691926]  [<ffffffff8100a41b>] cpu_idle+0xb2/0xcc
[94334.691929]  [<ffffffff8171673d>] start_secondary+0x216/0x218
[94334.691930] ---[ end trace 4bd208232dfb8438 ]---
[94334.692002] e1000e 0000:00:19.0 eth0: Reset adapter unexpectedly
[94336.539874] e1000e: eth0 NIC Link is Up 100 Mbps Full Duplex, Flow Control: Rx/Tx

Asus P8Z68-V PRO GEN3 mobo

00:00.0 Host bridge: Intel Corporation 2nd Generation Core Processor Family DRAM Controller (rev 09)
00:01.0 PCI bridge: Intel Corporation Xeon E3-1200/2nd Generation Core Processor Family PCI Express Root Port (rev 09)
00:02.0 VGA compatible controller: Intel Corporation 2nd Generation Core Processor Family Integrated Graphics Controller (rev 09)
00:16.0 Communication controller: Intel Corporation 6 Series/C200 Series Chipset Family MEI Controller #1 (rev 04)
00:19.0 Ethernet controller: Intel Corporation 82579V Gigabit Network Connection (rev 05)
00:1a.0 USB controller: Intel Corporation 6 Series/C200 Series Chipset Family USB Enhanced Host Controller #2 (rev 05)
00:1b.0 Audio device: Intel Corporation 6 Series/C200 Series Chipset Family High Definition Audio Controller (rev 05)
00:1c.0 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset Family PCI Express Root Port 1 (rev b5)
00:1c.1 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset Family PCI Express Root Port 2 (rev b5)
00:1c.3 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset Family PCI Express Root Port 4 (rev b5)
00:1c.4 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset Family PCI Express Root Port 5 (rev b5)
00:1c.6 PCI bridge: Intel Corporation 82801 PCI Bridge (rev b5)
00:1c.7 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset Family PCI Express Root Port 8 (rev b5)
00:1d.0 USB controller: Intel Corporation 6 Series/C200 Series Chipset Family USB Enhanced Host Controller #1 (rev 05)
00:1f.0 ISA bridge: Intel Corporation Z68 Express Chipset Family LPC Controller (rev 05)
00:1f.2 SATA controller: Intel Corporation 6 Series/C200 Series Chipset Family SATA AHCI Controller (rev 05)
00:1f.3 SMBus: Intel Corporation 6 Series/C200 Series Chipset Family SMBus Controller (rev 05)
03:00.0 USB controller: ASMedia Technology Inc. ASM1042 SuperSpeed USB Host Controller
04:00.0 SATA controller: JMicron Technology Corp. JMB362 SATA Controller (rev 10)
05:00.0 USB controller: ASMedia Technology Inc. ASM1042 SuperSpeed USB Host Controller
06:00.0 PCI bridge: ASMedia Technology Inc. ASM1083/1085 PCIe to PCI Bridge (rev 01)
07:02.0 FireWire (IEEE 1394): VIA Technologies, Inc. VT6306/7/8 [Fire II(M)] IEEE 1394 OHCI Controller (rev c0)
08:00.0 SATA controller: Marvell Technology Group Ltd. 88SE9172 SATA 6Gb/s Controller (rev 11)

qdisc htb 1: root refcnt 2 r2q 10 default 19 direct_packets_stat 0 ver 3.17
 Sent 90062531 bytes 993345 pkt (dropped 0, overlimits 6141 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc fq_codel 11: parent 1:11 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn 
 Sent 16968493 bytes 51685 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  maxpacket 1013 drop_overlimit 0 new_flow_count 23536 ecn_mark 0
  new_flows_len 1 old_flows_len 3
qdisc fq_codel 12: parent 1:12 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn 
 Sent 53860052 bytes 855858 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  maxpacket 256 drop_overlimit 0 new_flow_count 46440 ecn_mark 0
  new_flows_len 1 old_flows_len 0
qdisc fq_codel 13: parent 1:13 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn 
 Sent 123970 bytes 1401 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  maxpacket 256 drop_overlimit 0 new_flow_count 1199 ecn_mark 0
  new_flows_len 0 old_flows_len 1
qdisc fq_codel 19: parent 1:19 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn 
 Sent 348880 bytes 1937 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  maxpacket 1514 drop_overlimit 0 new_flow_count 112 ecn_mark 0
  new_flows_len 1 old_flows_len 0
qdisc fq_codel 20: parent 1:20 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn 
 Sent 88982 bytes 498 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  maxpacket 1514 drop_overlimit 0 new_flow_count 86 ecn_mark 0
  new_flows_len 0 old_flows_len 0
qdisc fq_codel 21: parent 1:21 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn 
 Sent 6092165 bytes 4221 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  maxpacket 1514 drop_overlimit 0 new_flow_count 71 ecn_mark 0
  new_flows_len 0 old_flows_len 0
qdisc fq_codel 22: parent 1:22 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn 
 Sent 6041816 bytes 5902 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  maxpacket 1514 drop_overlimit 0 new_flow_count 1472 ecn_mark 0
  new_flows_len 0 old_flows_len 1
qdisc fq_codel 30: parent 1:30 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn 
 Sent 5767604 bytes 72912 pkt (dropped 1319, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  maxpacket 256 drop_overlimit 0 new_flow_count 67956 ecn_mark 0
  new_flows_len 1 old_flows_len 0
qdisc fq_codel 31: parent 1:31 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn 
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  maxpacket 256 drop_overlimit 0 new_flow_count 0 ecn_mark 0
  new_flows_len 0 old_flows_len 0
qdisc fq_codel 32: parent 1:32 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn 
 Sent 963816 bytes 1431 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  maxpacket 1514 drop_overlimit 0 new_flow_count 241 ecn_mark 0
  new_flows_len 0 old_flows_len 0

class htb 1:22 parent 1:1 leaf 22: prio 2 quantum 1600 rate 200000bit ceil 100000Kbit burst 1600b/1 mpu 0b overhead 0b cburst 800000b/1 mpu 0b overhead 0b level 0 
 Sent 6041816 bytes 5902 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
 lended: 4294 borrowed: 1608 giants: 0
 tokens: 56280000 ctokens: 63984560

class htb 1:11 parent 1:1 leaf 11: prio 1 quantum 1600 rate 100000bit ceil 100000Kbit burst 1600b/1 mpu 0b overhead 0b cburst 1600000b/1 mpu 0b overhead 0b level 0 
 Sent 16969097 bytes 51689 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 480bit 0pps backlog 0b 0p requeues 0 
 lended: 43551 borrowed: 8138 giants: 0
 tokens: 116080000 ctokens: 127988080

class htb 1:32 parent 1:1 leaf 32: prio 4 quantum 1600 rate 100000bit ceil 100000Kbit burst 1600b/1 mpu 0b overhead 0b cburst 1600000b/1 mpu 0b overhead 0b level 0 
 Sent 963816 bytes 1431 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
 lended: 1385 borrowed: 46 giants: 0
 tokens: 122720000 ctokens: 127994720

class htb 1:1 root rate 100000Kbit ceil 100000Kbit burst 1600b/1 mpu 0b overhead 0b cburst 1600b/1 mpu 0b overhead 0b level 7 
 Sent 90071579 bytes 993458 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 7040bit 11pps backlog 0b 0p requeues 0 
 lended: 45569 borrowed: 0 giants: 0
 tokens: 122240 ctokens: 122240

class htb 1:31 parent 1:1 leaf 31: prio 4 quantum 1600 rate 100000bit ceil 100000Kbit burst 1600b/1 mpu 0b overhead 0b cburst 1600000b/1 mpu 0b overhead 0b level 0 
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
 lended: 0 borrowed: 0 giants: 0
 tokens: 128000000 ctokens: 128000

class htb 1:13 parent 1:1 leaf 13: prio 0 quantum 1600 rate 100000bit ceil 300000bit burst 1600b/1 mpu 0b overhead 0b cburst 4800b/1 mpu 0b overhead 0b level 0 
 Sent 124158 bytes 1403 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 56bit 0pps backlog 0b 0p requeues 0 
 lended: 1403 borrowed: 0 giants: 0
 tokens: 120800000 ctokens: 125600001

class htb 1:20 parent 1:1 leaf 20: prio 2 quantum 1600 rate 100000bit ceil 100000Kbit burst 1600b/1 mpu 0b overhead 0b cburst 1600000b/1 mpu 0b overhead 0b level 0 
 Sent 88982 bytes 498 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
 lended: 498 borrowed: 0 giants: 0
 tokens: 123680000 ctokens: 127995680

class htb 1:30 parent 1:1 leaf 30: prio 1 quantum 1600 rate 100000bit ceil 100000Kbit burst 1600b/1 mpu 0b overhead 0b cburst 1600000b/1 mpu 0b overhead 0b level 0 
 Sent 5582613 bytes 70519 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 6480bit 11pps backlog 0b 0p requeues 0 
 lended: 38294 borrowed: 32225 giants: 0
 tokens: 109923209 ctokens: 127994240

class htb 1:12 parent 1:1 leaf 12: prio 1 quantum 1600 rate 1000Kbit ceil 100000Kbit burst 1600b/1 mpu 0b overhead 0b cburst 160000b/1 mpu 0b overhead 0b level 0 
 Sent 53860052 bytes 855858 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
 lended: 855854 borrowed: 4 giants: 0
 tokens: 11978532 ctokens: 12794720

class htb 1:21 parent 1:1 leaf 21: prio 2 quantum 1600 rate 100000bit ceil 100000Kbit burst 1600b/1 mpu 0b overhead 0b cburst 1600000b/1 mpu 0b overhead 0b level 0 
 Sent 6092165 bytes 4221 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
 lended: 725 borrowed: 3496 giants: 0
 tokens: 123680000 ctokens: 127995680

class htb 1:19 parent 1:1 leaf 19: prio 3 quantum 1600 rate 100000bit ceil 100000Kbit burst 1600b/1 mpu 0b overhead 0b cburst 1600000b/1 mpu 0b overhead 0b level 0 
 Sent 348880 bytes 1937 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 24bit 0pps backlog 0b 0p requeues 0 
 lended: 1885 borrowed: 52 giants: 0
 tokens: 124640000 ctokens: 127996640

class fq_codel 11:d5 parent 11: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  deficit 1373 count 0 lastcount 0 ldelay 1us
class fq_codel 11:220 parent 11: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  deficit 1064 count 0 lastcount 0 ldelay 2us
class fq_codel 11:241 parent 11: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  deficit 173 count 0 lastcount 0 ldelay 1us
class fq_codel 11:2b9 parent 11: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  deficit 876 count 0 lastcount 0 ldelay 1us
class fq_codel 12:1b4 parent 12: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  deficit 1024 count 0 lastcount 0 ldelay 1us
class fq_codel 13:d7 parent 13: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  deficit 1424 count 0 lastcount 0 ldelay 1us
class fq_codel 13:2c2 parent 13: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  deficit 872 count 0 lastcount 0 ldelay 1us
class fq_codel 19:ba parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  deficit 590 count 0 lastcount 0 ldelay 1us
class fq_codel 22:25d parent 22: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  deficit 831 count 0 lastcount 0 ldelay 1us
class fq_codel 30:122 parent 30: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  deficit 1442 count 1 lastcount 1 ldelay 0us

Features for eth0:
rx-checksumming: on
tx-checksumming: on
        tx-checksum-ipv4: off [fixed]
        tx-checksum-ip-generic: on
        tx-checksum-ipv6: off [fixed]
        tx-checksum-fcoe-crc: off [fixed]
        tx-checksum-sctp: off [fixed]
scatter-gather: off
        tx-scatter-gather: off
        tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: off
        tx-tcp-segmentation: off [requested on]
        tx-tcp-ecn-segmentation: off [fixed]
        tx-tcp6-segmentation: off [requested on]
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: off
generic-receive-offload: off
large-receive-offload: off [fixed]
rx-vlan-offload: off
tx-vlan-offload: off
ntuple-filters: off [fixed]
receive-hashing: off
highdma: on [fixed]
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: on
loopback: off [fixed]
rx-fcs: off
rx-all: off


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
        Speed: 100Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 2
        Transceiver: internal
        Auto-negotiation: on
        MDI-X: on (auto)
        Supports Wake-on: pumbg
        Wake-on: g
        Current message level: 0x00000007 (7)
                               drv probe link
        Link detected: yes


NIC statistics:
     rx_packets: 1413394
     tx_packets: 994142
     rx_bytes: 1886827377
     tx_bytes: 96720549
     rx_broadcast: 42
     tx_broadcast: 1
     rx_multicast: 0
     tx_multicast: 6
     rx_errors: 0
     tx_errors: 0
     tx_dropped: 0
     multicast: 0
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_no_buffer_count: 0
     rx_missed_errors: 0
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     tx_window_errors: 0
     tx_abort_late_coll: 0
     tx_deferred_ok: 0
     tx_single_coll_ok: 0
     tx_multi_coll_ok: 0
     tx_timeout_count: 1
     tx_restart_queue: 0
     rx_long_length_errors: 0
     rx_short_length_errors: 0
     rx_align_errors: 0
     tx_tcp_seg_good: 0
     tx_tcp_seg_failed: 0
     rx_flow_control_xon: 33
     rx_flow_control_xoff: 123
     tx_flow_control_xon: 0
     tx_flow_control_xoff: 0
     rx_csum_offload_good: 1411434
     rx_csum_offload_errors: 2
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

then I reloaded the module..

# ethtool -t eth0
The test result is PASS
The test extra info:
Register test  (offline)         0
Eeprom test    (offline)         0
Interrupt test (offline)         0
Loopback test  (offline)         0
Link test   (on/offline)         0



-- 
Do what you love because life is too short for anything else.

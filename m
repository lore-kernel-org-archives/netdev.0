From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: packetloss, on e1000e worse than r8169?
Date: Mon, 16 Jun 2008 23:23:25 +0300
Message-ID: <20080616202210.M84100@visp.net.lb>
References: <20080616193501.M64730@visp.net.lb> <4856C3A7.9070703@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org, linux.nics@intel.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:50110 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753685AbYFPUXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 16:23:44 -0400
In-Reply-To: <4856C3A7.9070703@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also if important
MegaRouter-KARAM ~ # dmesg|grep eth1
[    3.955620] eth1: (PCI Express:2.5GB/s:Width x1) 00:19:d1:71:5f:33
[    3.955622] eth1: Intel(R) PRO/1000 Network Connection
[    3.955642] eth1: MAC: 4, PHY: 6, PBA No: ffffff-0ff
[    5.358191] netconsole: interface eth1
[    6.432345] eth1: Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX

MegaRouter-KARAM ~ # ethtool eth1
Settings for eth1:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Advertised auto-negotiation: Yes
        Speed: 1000Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: pumbag
        Wake-on: g
        Current message level: 0x00000001 (1)
        Link detected: yes


MegaRouter-KARAM ~ # ethtool -c eth1
Coalesce parameters for eth1:
Adaptive RX: off  TX: off
stats-block-usecs: 0
sample-interval: 0
pkt-rate-low: 0
pkt-rate-high: 0

rx-usecs: 3

I tried to change Intel's "magic" rx-usecs to 0,1,3,10000,100000, it doesn't
help at all. Attempt to change offloading parameters (disabling) doesn't make
sense too.


On Mon, 16 Jun 2008 21:48:55 +0200, Eric Dumazet wrote
> Denys Fedoryshchenko a e'crit :
> > Hi again
> > 
> > I moved from PCI Realtek 8169 to onboard PCI-Express e1000e, and situation
> > become worse. Strange? Yes.
> > 
> > Here is info
> > Load and error rate: 
> > 
> > MegaRouter-KARAM /sys # ifconfig eth1;sleep 10;ifconfig eth1
> > eth1      Link encap:Ethernet  HWaddr 00:19:D1:71:5F:33
> >           inet addr:192.168.20.10  Bcast:0.0.0.0  Mask:255.255.255.0
> >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> >           RX packets:91991642 errors:0 dropped:1803444 overruns:0 frame:0
> >           TX packets:91914611 errors:0 dropped:0 overruns:0 carrier:0
> >           collisions:0 txqueuelen:1000
> >           RX bytes:316112765 (301.4 MiB)  TX bytes:138303107 (131.8 MiB)
> >           Memory:90300000-90320000
> > 
> > eth1      Link encap:Ethernet  HWaddr 00:19:D1:71:5F:33
> >           inet addr:192.168.20.10  Bcast:0.0.0.0  Mask:255.255.255.0
> >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> >           RX packets:92812514 errors:0 dropped:1815490 overruns:0 frame:0
> >           TX packets:92734865 errors:0 dropped:0 overruns:0 carrier:0
> >           collisions:0 txqueuelen:1000
> >           RX bytes:739941322 (705.6 MiB)  TX bytes:560547138 (534.5 MiB)
> >           Memory:90300000-90320000
> > 
> > System load (there is no NAT, no shapers, just routing, around 600-700
routes):
> > MegaRouter-KARAM /sys # mpstat 1
> > Linux 2.6.26-rc6-git2-build-0029 (MegaRouter-KARAM)     06/16/08
> > 
> > 22:36:36     CPU   %user   %nice    %sys %iowait    %irq   %soft  %steal  
> > %idle    intr/s
> > 22:36:37     all    0.00    0.00    0.00    0.00    0.00    1.49    0.00  
> > 98.51  19764.00
> > 22:36:38     all    0.00    0.00    0.50    0.00    0.00    0.50    0.00  
> > 99.01  19888.00
> > 22:36:39     all    0.00    0.00    0.00    0.00    0.00    0.50    0.00  
> > 99.50  19642.00
> > 22:36:40     all    0.00    0.00    0.00    0.00    1.01    9.05    0.00  
> > 89.95  19543.00
> > 
> > (system almost idle)
> > 
> > MegaRouter-KARAM /sys # ethtool -S eth1
> > NIC statistics:
> >      rx_packets: 109977509
> >      tx_packets: 109887692
> >      rx_bytes: 57656749138
> >      tx_bytes: 57536071746
> >      rx_broadcast: 6497
> >      tx_broadcast: 92
> >      rx_multicast: 48995
> >      tx_multicast: 1960
> >      rx_errors: 0
> >      tx_errors: 0
> >      tx_dropped: 0
> >      multicast: 48995
> >      collisions: 0
> >      rx_length_errors: 0
> >      rx_over_errors: 0
> >      rx_crc_errors: 0
> >      rx_frame_errors: 0
> >      rx_no_buffer_count: 1796
> >      rx_missed_errors: 2182679
> >      tx_aborted_errors: 0
> >      tx_carrier_errors: 0
> >      tx_fifo_errors: 0
> >      tx_heartbeat_errors: 0
> >      tx_window_errors: 0
> >      tx_abort_late_coll: 0
> >      tx_deferred_ok: 55617
> >      tx_single_coll_ok: 0
> >      tx_multi_coll_ok: 0
> >      tx_timeout_count: 0
> >      tx_restart_queue: 1626
> >      rx_long_length_errors: 0
> >      rx_short_length_errors: 0
> >      rx_align_errors: 0
> >      tx_tcp_seg_good: 0
> >      tx_tcp_seg_failed: 0
> >      rx_flow_control_xon: 55461
> >      rx_flow_control_xoff: 57329
> >      tx_flow_control_xon: 39114
> >      tx_flow_control_xoff: 48341
> >      rx_long_byte_count: 57656749138
> >      rx_csum_offload_good: 104097306
> >      rx_csum_offload_errors: 2209
> >      rx_header_split: 0
> >      alloc_rx_buff_failed: 0
> >      tx_smbus: 22
> >      rx_smbus: 2201
> >      dropped_smbus: 0
> >      rx_dma_failed: 0
> >      tx_dma_failed: 0
> > MegaRouter-KARAM /sys # ethtool -S eth1
> > NIC statistics:
> >      rx_packets: 110154571
> >      tx_packets: 110064459
> >      rx_bytes: 57753358981
> >      tx_bytes: 57632419451
> >      rx_broadcast: 6501
> >      tx_broadcast: 92
> >      rx_multicast: 49155
> >      tx_multicast: 1960
> >      rx_errors: 0
> >      tx_errors: 0
> >      tx_dropped: 0
> >      multicast: 49155
> >      collisions: 0
> >      rx_length_errors: 0
> >      rx_over_errors: 0
> >      rx_crc_errors: 0
> >      rx_frame_errors: 0
> >      rx_no_buffer_count: 1796
> >      rx_missed_errors: 2187703
> >      tx_aborted_errors: 0
> >      tx_carrier_errors: 0
> >      tx_fifo_errors: 0
> >      tx_heartbeat_errors: 0
> >      tx_window_errors: 0
> >      tx_abort_late_coll: 0
> >      tx_deferred_ok: 55772
> >      tx_single_coll_ok: 0
> >      tx_multi_coll_ok: 0
> >      tx_timeout_count: 0
> >      tx_restart_queue: 1628
> >      rx_long_length_errors: 0
> >      rx_short_length_errors: 0
> >      rx_align_errors: 0
> >      tx_tcp_seg_good: 0
> >      tx_tcp_seg_failed: 0
> >      rx_flow_control_xon: 55615
> >      rx_flow_control_xoff: 57488
> >      tx_flow_control_xon: 39209
> >      tx_flow_control_xoff: 48448
> >      rx_long_byte_count: 57753358981
> >      rx_csum_offload_good: 104264656
> >      rx_csum_offload_errors: 2210
> >      rx_header_split: 0
> >      alloc_rx_buff_failed: 0
> >      tx_smbus: 23
> >      rx_smbus: 2207
> >      dropped_smbus: 0
> >      rx_dma_failed: 0
> >      tx_dma_failed: 0
> > 
> > 
> >
> 
> What RX & TX rings look like on e1000e ?
> 
> ethtool -g eth1
> 
> Also, please post "cat /proc/interrupts"
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.


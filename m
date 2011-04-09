From: Wei Gu <wei.gu@ericsson.com>
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Sat, 9 Apr 2011 11:36:07 +0800
Message-ID: <D12839161ADD3A4B8DA63D1A134D084026E48BA6AF@ESGSCCMS0001.eapac.ericsson.se>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	 <1302152327.2701.50.camel@edumazet-laptop>
	 <1302153412.2701.64.camel@edumazet-laptop>
	 <1302157012.2701.73.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9E82@ESGSCCMS0001.eapac.ericsson.se>
	 <1302163650.3357.8.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9F23@ESGSCCMS0001.eapac.ericsson.se>
	 <1302167168.3357.12.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA027@ESGSCCMS0001.eapac.ericsson.se>
	 <1302176811.3357.15.camel@edumazet-laptop>  <4D9DDF43.9080302@intel.com>
	 <1302192218.3357.47.camel@edumazet-laptop> <4D9DE465.1080008@intel.com>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA58D@ESGSCCMS0001.eapac.ericsson.se>
 <1302253651.4409.2.camel@edumazet-laptop>
 <D12839161ADD3A4B8DA63D1A134D084026E48BA66B@ESGSCCMS0001.eapac.ericsson.se>
 <4D9F3629.9020506@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:47668 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752550Ab1DIDgN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 23:36:13 -0400
In-Reply-To: <4D9F3629.9020506@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexander,
I do agree with you that if only the rx_missing_error (rx_no_buffer_count: 0) indicates the memory bandwidth issue. But the strange thing is I using the same test configuration on Linux 2.6.32, which looks no this problem at all. SO it not a HW setup problem at all, only difference in on the Kernel version, that's why I go back to you guys for this new Linux 2.6.38, if it will affact this memory bandwidth Or BIOS etc things?

The follow dump is done, while I was try to receive 290Kpps 400Byte pakets from IXIA, and drop them in the prerouting hook.
I bind the eth10 8 RX queue to CPU sock ID 3 ( core 24-31) on NUMA NODE3

ethtool -i eth10
driver: ixgbe
version: 3.2.10-NAPI
firmware-version: 0.9-3
bus-info: 0000:8d:00.0

ethtool -S eth10
NIC statistics:
     rx_packets: 14222510
     tx_packets: 109
     rx_bytes: 5575223920
     tx_bytes: 17790
     rx_errors: 0
     tx_errors: 0
     rx_dropped: 0
     tx_dropped: 0
     multicast: 0
     collisions: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_fifo_errors: 0
     rx_missed_errors: 15150244
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     rx_pkts_nic: 14226186
     tx_pkts_nic: 109
     rx_bytes_nic: 11750580400
     tx_bytes_nic: 18642
     lsc_int: 2
     tx_busy: 0
     non_eop_descs: 0
     broadcast: 0
     rx_no_buffer_count: 0
     tx_timeout_count: 0
     tx_restart_queue: 0
     rx_long_length_errors: 0
     rx_short_length_errors: 0
     tx_flow_control_xon: 0
     rx_flow_control_xon: 0
     tx_flow_control_xoff: 0
     rx_flow_control_xoff: 0
     rx_csum_offload_errors: 0
     low_latency_interrupt: 0
     alloc_rx_page_failed: 0
     alloc_rx_buff_failed: 0
     lro_aggregated: 0
     lro_flushed: 0
     lro_recycled: 0
     rx_no_dma_resources: 0
     hw_rsc_aggregated: 0
     hw_rsc_flushed: 0
     rx_flm: 0
     fdir_match: 0
     fdir_miss: 0
     fdir_overflow: 0
     fcoe_bad_fccrc: 0
     fcoe_last_errors: 0
     rx_fcoe_dropped: 0
     rx_fcoe_packets: 0
     rx_fcoe_dwords: 0
     tx_fcoe_packets: 0
     tx_fcoe_dwords: 0
     tx_queue_0_packets: 0
     tx_queue_0_bytes: 0
     tx_queue_1_packets: 10
     tx_queue_1_bytes: 540
     tx_queue_2_packets: 0
     tx_queue_2_bytes: 0
     tx_queue_3_packets: 0
     tx_queue_3_bytes: 0
     tx_queue_4_packets: 30
     tx_queue_4_bytes: 2340
     tx_queue_5_packets: 4
     tx_queue_5_bytes: 1368
     tx_queue_6_packets: 65
     tx_queue_6_bytes: 13542
     tx_queue_7_packets: 0
     tx_queue_7_bytes: 0
     rx_queue_0_packets: 1777898
     rx_queue_0_bytes: 696936016
     rx_queue_1_packets: 1777207
     rx_queue_1_bytes: 696665144
     rx_queue_2_packets: 1778379
     rx_queue_2_bytes: 697124568
     rx_queue_3_packets: 1777891
     rx_queue_3_bytes: 696933272
     rx_queue_4_packets: 1777050
     rx_queue_4_bytes: 696603600
     rx_queue_5_packets: 1777915
     rx_queue_5_bytes: 696942680
     rx_queue_6_packets: 1778737
     rx_queue_6_bytes: 697264904
     rx_queue_7_packets: 1778391
     rx_queue_7_bytes: 697129272

Lspci dump:

00:00.0 Host bridge: Intel Corporation 5520/5500/X58 I/O Hub to ESI Port (rev 22)
00:01.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 1 (rev 22)
00:02.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 2 (rev 22)
00:03.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 3 (rev 22)
00:04.0 PCI bridge: Intel Corporation 5520/X58 I/O Hub PCI Express Root Port 4 (rev 22)
00:05.0 PCI bridge: Intel Corporation 5520/X58 I/O Hub PCI Express Root Port 5 (rev 22)
00:06.0 PCI bridge: Intel Corporation 5520/X58 I/O Hub PCI Express Root Port 6 (rev 22)
00:07.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 7 (rev 22)
00:08.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 8 (rev 22)
00:09.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 9 (rev 22)
00:0a.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 10 (rev 22)
00:14.0 PIC: Intel Corporation 5520/5500/X58 I/O Hub System Management Registers (rev 22)
00:14.1 PIC: Intel Corporation 5520/5500/X58 I/O Hub GPIO and Scratch Pad Registers (rev 22)
00:14.2 PIC: Intel Corporation 5520/5500/X58 I/O Hub Control Status and RAS Registers (rev 22)
00:1c.0 PCI bridge: Intel Corporation 82801JI (ICH10 Family) PCI Express Root Port 1
00:1c.4 PCI bridge: Intel Corporation 82801JI (ICH10 Family) PCI Express Root Port 5
00:1d.0 USB Controller: Intel Corporation 82801JI (ICH10 Family) USB UHCI Controller #1
00:1d.1 USB Controller: Intel Corporation 82801JI (ICH10 Family) USB UHCI Controller #2
00:1d.2 USB Controller: Intel Corporation 82801JI (ICH10 Family) USB UHCI Controller #3
00:1d.3 USB Controller: Intel Corporation 82801JI (ICH10 Family) USB UHCI Controller #6
00:1d.7 USB Controller: Intel Corporation 82801JI (ICH10 Family) USB2 EHCI Controller #1
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 90)
00:1f.0 ISA bridge: Intel Corporation 82801JIB (ICH10) LPC Interface Controller
00:1f.2 IDE interface: Intel Corporation 82801JI (ICH10 Family) 4 port SATA IDE Controller #1
01:03.0 VGA compatible controller: ATI Technologies Inc ES1000 (rev 02)
02:00.0 System peripheral: Hewlett-Packard Company iLO3 Slave instrumentation & System support (rev 04)
02:00.2 System peripheral: Hewlett-Packard Company iLO3 Management Processor Support and Messaging (rev 04)
02:00.4 USB Controller: Hewlett-Packard Company Proliant iLO2/iLO3 virtual USB controller (rev 01)
03:00.0 RAID bus controller: Hewlett-Packard Company Smart Array G6 controllers (rev 01)
04:00.0 Ethernet controller: NetXen Incorporated NX3031 Multifunction 1/10-Gigabit Server Adapter (rev 42)
04:00.1 Ethernet controller: NetXen Incorporated NX3031 Multifunction 1/10-Gigabit Server Adapter (rev 42)
04:00.2 Ethernet controller: NetXen Incorporated NX3031 Multifunction 1/10-Gigabit Server Adapter (rev 42)
04:00.3 Ethernet controller: NetXen Incorporated NX3031 Multifunction 1/10-Gigabit Server Adapter (rev 42)
0b:00.0 Ethernet controller: Intel Corporation 82599EB 10-Gigabit Network Connection (rev 01)
0b:00.1 Ethernet controller: Intel Corporation 82599EB 10-Gigabit Network Connection (rev 01)
11:00.0 Ethernet controller: Intel Corporation 82599EB 10-Gigabit Network Connection (rev 01)
11:00.1 Ethernet controller: Intel Corporation 82599EB 10-Gigabit Network Connection (rev 01)
80:00.0 PCI bridge: Intel Corporation 5500 Non-Legacy I/O Hub PCI Express Root Port 0 (rev 22)
80:01.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 1 (rev 22)
80:02.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 2 (rev 22)
80:03.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 3 (rev 22)
80:04.0 PCI bridge: Intel Corporation 5520/X58 I/O Hub PCI Express Root Port 4 (rev 22)
80:05.0 PCI bridge: Intel Corporation 5520/X58 I/O Hub PCI Express Root Port 5 (rev 22)
80:06.0 PCI bridge: Intel Corporation 5520/X58 I/O Hub PCI Express Root Port 6 (rev 22)
80:07.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 7 (rev 22)
80:08.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 8 (rev 22)
80:09.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 9 (rev 22)
80:0a.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 10 (rev 22)
80:14.0 PIC: Intel Corporation 5520/5500/X58 I/O Hub System Management Registers (rev 22)
80:14.1 PIC: Intel Corporation 5520/5500/X58 I/O Hub GPIO and Scratch Pad Registers (rev 22)
80:14.2 PIC: Intel Corporation 5520/5500/X58 I/O Hub Control Status and RAS Registers (rev 22)
8d:00.0 Ethernet controller: Intel Corporation 82599EB 10-Gigabit Network Connection (rev 01)
8d:00.1 Ethernet controller: Intel Corporation 82599EB 10-Gigabit Network Connection (rev 01)
90:00.0 Ethernet controller: Intel Corporation 82599EB 10-Gigabit Network Connection (rev 01)
90:00.1 Ethernet controller: Intel Corporation 82599EB 10-Gigabit Network Connection (rev 01)

-----Original Message-----
From: Alexander Duyck [mailto:alexander.h.duyck@intel.com]
Sent: Saturday, April 09, 2011 12:22 AM
To: Wei Gu
Cc: Eric Dumazet; netdev; Kirsher, Jeffrey T
Subject: Re: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel

On 4/8/2011 5:19 AM, Wei Gu wrote:
> Hi again,
> I tried more testing with by disable this CONFIG_DMAR with shipped 2.6.38 ixgbe and Intel released 3.2.10/3.1.15.
> All these test looks we can get>1Mpps 400bype packtes but not stable at all, there will huge number missing errors with 100% CPU IDLE:
> ethtool -S eth10 |grep rx_missed_errors
>
>          rx_missed_errors: 76832040
>
> SUM: 1102212 ETH8: 0  ETH10: 1102212 ETH6: 0 ETH4: 0
> SUM: 521841 ETH8: 0  ETH10: 521841 ETH6: 0 ETH4: 0
> SUM: 426776 ETH8: 0  ETH10: 426776 ETH6: 0 ETH4: 0
> SUM: 927520 ETH8: 0  ETH10: 927520 ETH6: 0 ETH4: 0
> SUM: 1171995 ETH8: 0  ETH10: 1171995 ETH6: 0 ETH4: 0
> SUM: 855980 ETH8: 0  ETH10: 855980 ETH6: 0 ETH4: 0
>
>
> Do you know if there is other options in the kernel will cause high
> rate rx_missed_errors with low CPU usage. (No problem on 2.6.32 with
> same test case)
>
> perf  record:
> +     69.74%          swapper  [kernel.kallsyms]          [k] poll_idle
> +     11.62%          swapper  [kernel.kallsyms]          [k] intel_idle
> +      0.80%          swapper  [ixgbe]                    [k] ixgbe_poll
> +      0.79%             perf  [ixgbe]                    [k] ixgbe_poll
> +      0.77%             perf  [kernel.kallsyms]          [k] skb_copy_bits
> +      0.64%          swapper  [kernel.kallsyms]          [k] skb_copy_bits
> +      0.48%             perf  [kernel.kallsyms]          [k] __kmalloc_node_track_caller
> +      0.44%          swapper  [kernel.kallsyms]          [k] __kmalloc_node_track_caller
> +      0.36%          swapper  [kernel.kallsyms]          [k] kmem_cache_alloc_node
> +      0.35%          swapper  [kernel.kallsyms]          [k] kfree
> +      0.35%             perf  [kernel.kallsyms]          [k] kmem_cache_alloc_node

I was wondering if you could dump all of your ethtool stats instead of just the rx_missed_errors as this will provide us with much more info to work with.

I'm mainly interested in seeing if the rx_no_buffer_count is incrementing as well.  If it is not then what you may be seeing is a bus bandwidth issue depending on what slot you are in.

Also if you could provide an lspci dump for the part that would also give us some additional information on your PCIe bus configuration.

Thanks,

Alex

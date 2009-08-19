From: Bill Fink <billfink@mindspring.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Wed, 19 Aug 2009 13:59:00 -0400
Message-ID: <20090819135900.9cc50e73.billfink@mindspring.com>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>
	<4A7C9A14.7070600@inria.fr>
	<20090807175112.a1f57407.billfink@mindspring.com>
	<4A7CCEFC.7020308@myri.com>
	<20090807213557.d0faec23.billfink@mindspring.com>
	<4A7D5CA4.3030307@myri.com>
	<20090808112636.GB18518@localhost.localdomain>
	<4A7DC230.6060206@myri.com>
	<20090808183251.GA23300@localhost.localdomain>
	<20090811033210.6b422ed1.billfink@mindspring.com>
	<F169D4F5E1F1974DBFAFABF47F60C10A36523146@orsmsx507.amr.corp.intel.com>
	<20090812003824.26c9c8fb.billfink@mindspring.com>
	<20090814163155.968872fe.billfink@mindspring.com>
	<20090817095302.0c41ef68@jbarnes-g45>
	<20090818030718.aef199f4.billfink@mindspring.com>
	<4A8A9671.8060002@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Brice Goglin <Brice.Goglin@inria.fr>,
	Linux Network Developers <netdev@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-kukur.atl.sa.earthlink.net ([209.86.89.65]:51401 "EHLO
	elasmtp-kukur.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751667AbZHSR7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 13:59:12 -0400
In-Reply-To: <4A8A9671.8060002@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Aug 2009, Andrew Gallatin wrote:

> Bill Fink wrote:
> 
> > <         Latency: 0, Cache Line Size: 64 bytes
> 
> <...>
> 
> >>       Latency: 0, Cache Line Size: 256 bytes
> 
> 
> A cache line size of 256 clearly seems wrong for a Xeon.  I assume all
> devices on the SuperMicro show the same value?

I forgot to check that.

> > Interestingly, the "WC Enabled" is only indicated on the first two
> 
> The WC is probably a red herring.
> 
> What does ethtool -S show for the DMA write bandwidth of the
> NICs on the SuperMicro?

I've attached the full "ethtool -S" output from both the Asus and
SuperMicro systems.  Here's just the bandwidth info:

Asus eth2:

[root@i7test1 ~]# ethtool -S eth2
NIC statistics:
...
     read_dma_bw_MBs: 1625
     write_dma_bw_MBs: 1599
     read_write_dma_bw_MBs: 3192

SuperMicro eth2 (on 5520 connected to NUMA node 1):

[root@xeontest1 ~]# ethtool -S eth2
NIC statistics:
...
     read_dma_bw_MBs: 1624
     write_dma_bw_MBs: 1605
     read_write_dma_bw_MBs: 1323

SuperMicro eth8 (on 5520 connected to NUMA node 0):

[root@xeontest1 ~]# ethtool -S eth8
NIC statistics:
...
     read_dma_bw_MBs: 1572
     write_dma_bw_MBs: 1605
     read_write_dma_bw_MBs: 2113

> These values are obtained serially, as the driver resets
> the NIC (reset happens at load time, and ifconfig up),
> so they could easily sum to more than the memory bandwidth
> of the system.  But it would be good to check for any anomalies.
> 
> I can send you a pointer to a tool we use internally, which loads
> some custom firmware on the NIC, and can exercise the DMA engines
> on all the NICs in parallel.  This would give an idea of the
> aggregate DMA bandwidth available on the system.  Let me know
> if you're interested.

Yes, I'd be interested.

						-Thanks

						-Bill



Full ethtool output:
--------------------------------------------------------------------------------

Asus eth2:

[root@i7test1 ~]# ethtool -S eth2
NIC statistics:
     rx_packets: 4
     tx_packets: 10
     rx_bytes: 240
     tx_bytes: 708
     rx_errors: 0
     tx_errors: 0
     rx_dropped: 0
     tx_dropped: 0
     multicast: 0
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_fifo_errors: 0
     rx_missed_errors: 0
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     tx_window_errors: 0
     tx_boundary: 4096
     WC: 0
     irq: 2282
     MSI: 1
     MSIX: 0
     read_dma_bw_MBs: 1625
     write_dma_bw_MBs: 1599
     read_write_dma_bw_MBs: 3192
     serial_number: 356055
     watchdog_resets: 0
     link_changes: 6
     link_up: 1
     dropped_link_overflow: 0
     dropped_link_error_or_filtered: 631516
     dropped_pause: 631516
     dropped_bad_phy: 0
     dropped_bad_crc32: 0
     dropped_unicast_filtered: 0
     dropped_multicast_filtered: 11
     dropped_runt: 0
     dropped_overrun: 0
     dropped_no_small_buffer: 0
     dropped_no_big_buffer: 0
     ----------- slice ---------: 0
     tx_pkt_start: 421736
     tx_pkt_done: 421736
     tx_req: 2866189
     tx_done: 2866189
     rx_small_cnt: 257731
     rx_big_cnt: 3830824
     wake_queue: 5698
     stop_queue: 5698
     tx_linearized: 0
     LRO aggregated: 1276950
     LRO flushed: 264545
     LRO avg aggr: 4
     LRO no_desc: 0

SuperMicro eth2 (on 5520 connected to NUMA node 1):

[root@xeontest1 ~]# ethtool -S eth2
NIC statistics:
     rx_packets: 0
     tx_packets: 10
     rx_bytes: 0
     tx_bytes: 708
     rx_errors: 0
     tx_errors: 0
     rx_dropped: 0
     tx_dropped: 0
     multicast: 0
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_fifo_errors: 0
     rx_missed_errors: 0
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     tx_window_errors: 0
     tx_boundary: 4096
     WC: 0
     irq: 112
     MSI: 1
     MSIX: 0
     read_dma_bw_MBs: 1624
     write_dma_bw_MBs: 1605
     read_write_dma_bw_MBs: 1323
     serial_number: 363134
     watchdog_resets: 0
     dca_capable_firmware: 1
     dca_device_present: 0
     link_changes: 2
     link_up: 1
     dropped_link_overflow: 0
     dropped_link_error_or_filtered: 200
     dropped_pause: 200
     dropped_bad_phy: 0
     dropped_bad_crc32: 0
     dropped_unicast_filtered: 0
     dropped_multicast_filtered: 0
     dropped_runt: 0
     dropped_overrun: 0
     dropped_no_small_buffer: 0
     dropped_no_big_buffer: 0
     ----------- slice ---------: 0
     tx_pkt_start: 440223
     tx_pkt_done: 440223
     tx_req: 3412102
     tx_done: 3412102
     rx_small_cnt: 213976
     rx_big_cnt: 3071854
     wake_queue: 1846
     stop_queue: 1846
     tx_linearized: 0
     LRO aggregated: 1024029
     LRO flushed: 269709
     LRO avg aggr: 3
     LRO no_desc: 0

SuperMicro eth8 (on 5520 connected to NUMA node 0):

[root@xeontest1 ~]# ethtool -S eth8
NIC statistics:
     rx_packets: 11
     tx_packets: 16
     rx_bytes: 864
     tx_bytes: 1228
     rx_errors: 0
     tx_errors: 0
     rx_dropped: 0
     tx_dropped: 0
     multicast: 0
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_fifo_errors: 0
     rx_missed_errors: 0
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     tx_window_errors: 0
     tx_boundary: 4096
     WC: 0
     irq: 118
     MSI: 1
     MSIX: 0
     read_dma_bw_MBs: 1572
     write_dma_bw_MBs: 1605
     read_write_dma_bw_MBs: 2113
     serial_number: 361233
     watchdog_resets: 0
     dca_capable_firmware: 1
     dca_device_present: 0
     link_changes: 4
     link_up: 1
     dropped_link_overflow: 0
     dropped_link_error_or_filtered: 224
     dropped_pause: 224
     dropped_bad_phy: 0
     dropped_bad_crc32: 0
     dropped_unicast_filtered: 0
     dropped_multicast_filtered: 0
     dropped_runt: 0
     dropped_overrun: 0
     dropped_no_small_buffer: 0
     dropped_no_big_buffer: 0
     ----------- slice ---------: 0
     tx_pkt_start: 575354
     tx_pkt_done: 575354
     tx_req: 3590761
     tx_done: 3590761
     rx_small_cnt: 227078
     rx_big_cnt: 4733499
     wake_queue: 2199
     stop_queue: 2199
     tx_linearized: 0
     LRO aggregated: 1578229
     LRO flushed: 404901
     LRO avg aggr: 3
     LRO no_desc: 0

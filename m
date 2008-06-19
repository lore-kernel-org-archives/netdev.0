From: =?ISO-8859-1?Q?Anders_Grafstr=F6m?= <grfstrm@users.sourceforge.net>
Subject: Re: [PATCH] Fix e100 on systems that have cache
	incoherent DMA
Date: Thu, 19 Jun 2008 14:38:33 +0200
Message-ID: <485A5349.6070601@users.sourceforge.net>
References: <20071108181741.8648.61629.stgit@localhost.localdomain>
	<474DBDA6.50705@roinet.com> <474DBFCE.8010101@intel.com>
	<474DC0F3.8070604@garzik.org> <474DC68D.9020003@roinet.com>
	<485959DC.80902@users.sourceforge.net>
	<48595F16.5000905@roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com, miltonm@bga.com,
	akpm@linux-foundation.org
To: David Acker <dacker@roinet.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <48595F16.5000905@roinet.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

David Acker wrote:
> May I ask what actual board you are using and how the e100 is connected 
> to it?  I plan to test with miniPCI based e100 cards.  Also, can you say 
> more about it being broke?  Does it crash immediately, fail to move any 
> data, move some data and stop, etc. ?

It's a custom board based on the IXDP425 reference design.
IXP420 with 82551ER integrated on the same board.
Both RX and TX appears to stop shortly after the driver has been initialized.
It never recovers after the "exec cuc_dump_reset failed" messages start to show.

[42949402.380000] e100: eth0: e100_hw_init: e100_hw_init
[42949402.460000] e100: eth0: e100_phy_init: phy_addr = 1
[42949402.470000] e100: eth0: e100_phy_init: phy ID = 0x015402A8
[42949402.490000] e100: eth0: e100_configure: [00-07]=20:08:00:01:00:00:26:07
[42949402.490000] e100: eth0: e100_configure: [08-15]=01:00:2E:00:60:00:F2:48
[42949402.490000] e100: eth0: e100_configure: [16-23]=00:40:FA:86:3F:05:01:00
[42949402.490000] e100: eth0: e100_set_multicast_list: mc_count=0, flags=0x5002
[42949402.490000] e100: eth0: e100_configure: [00-07]=20:08:00:01:00:00:26:07
[42949402.490000] e100: eth0: e100_configure: [08-15]=01:00:2E:00:60:00:F2:48
[42949402.490000] e100: eth0: e100_configure: [16-23]=00:40:FA:86:3F:05:01:00
[42949402.490000] e100: eth0: e100_intr: stat_ack = 0x20
[42949402.490000] e100: eth0: e100_rx_indicate: status=0x0000
[42949402.490000] e100: eth0: e100_tx_clean: cb[0]->status = 0xA000
[42949402.490000] e100: eth0: e100_tx_clean: cb[1]->status = 0xA000
[42949402.490000] e100: eth0: e100_tx_clean: cb[2]->status = 0xA000
[42949402.490000] e100: eth0: e100_tx_clean: cb[3]->status = 0xA000
[42949402.490000] e100: eth0: e100_tx_clean: cb[4]->status = 0xA000
[42949402.490000] e100: eth0: e100_set_multicast_list: mc_count=0, flags=0x5003
[42949402.490000] e100: eth0: e100_configure: [00-07]=20:08:00:01:00:00:26:07
[42949402.490000] e100: eth0: e100_configure: [08-15]=01:00:2E:00:60:00:F2:48
[42949402.490000] e100: eth0: e100_configure: [16-23]=00:40:FA:86:3F:05:01:00
[42949402.490000] e100: eth0: e100_intr: stat_ack = 0x20
[42949402.490000] e100: eth0: e100_rx_indicate: status=0x0000
[42949402.490000] e100: eth0: e100_tx_clean: cb[5]->status = 0xA000
[42949402.490000] e100: eth0: e100_tx_clean: cb[6]->status = 0xA000
[42949402.490000] e100: eth0: e100_set_multicast_list: mc_count=1, flags=0x5003
[42949402.490000] e100: eth0: e100_configure: [00-07]=20:08:00:01:00:00:26:07
[42949402.490000] e100: eth0: e100_configure: [08-15]=01:00:2E:00:60:00:F2:48
[42949402.490000] e100: eth0: e100_configure: [16-23]=00:40:FA:86:3F:05:01:00
[42949402.490000] e100: eth0: e100_intr: stat_ack = 0x20
[42949402.490000] e100: eth0: e100_rx_indicate: status=0x0000
[42949402.490000] e100: eth0: e100_tx_clean: cb[7]->status = 0xA000
[42949402.490000] e100: eth0: e100_tx_clean: cb[8]->status = 0xA000
[42949402.500000] e100: eth0: e100_watchdog: right now = -27046
[42949402.500000] e100: eth0: e100_watchdog: link up, 100Mbps, half-duplex
[42949402.510000] e100: eth0: e100_intr: stat_ack = 0x04
[42949402.510000] e100: eth0: e100_rx_indicate: status=0x0000
[42949402.510000] e100: eth0: e100_set_multicast_list: mc_count=1, flags=0x5003
[42949402.510000] e100: eth0: e100_configure: [00-07]=20:08:00:01:00:00:26:07
[42949402.510000] e100: eth0: e100_configure: [08-15]=01:00:2E:00:60:00:F2:48
[42949402.510000] e100: eth0: e100_configure: [16-23]=00:40:FA:86:3F:05:01:00
[42949402.510000] e100: eth0: e100_intr: stat_ack = 0x20
[42949402.510000] e100: eth0: e100_rx_indicate: status=0x0000
[42949402.510000] e100: eth0: e100_tx_clean: cb[9]->status = 0xA000
[42949402.510000] e100: eth0: e100_tx_clean: cb[10]->status = 0xA000
[42949402.550000] e100: eth0: e100_configure: [00-07]=20:08:00:01:00:00:26:07
[42949402.550000] e100: eth0: e100_configure: [08-15]=01:00:2E:00:60:00:F2:48
[42949402.550000] e100: eth0: e100_configure: [16-23]=00:40:FA:86:3F:05:01:00
[42949402.550000] e100: eth0: e100_intr: stat_ack = 0x20
[42949402.550000] e100: eth0: e100_rx_indicate: status=0x0000
[42949402.550000] e100: eth0: e100_tx_clean: cb[11]->status = 0xA000
[42949402.550000] e100: eth0: e100_intr: stat_ack = 0x20
[42949402.550000] e100: eth0: e100_rx_indicate: status=0x0000
[42949402.550000] e100: eth0: e100_tx_clean: cb[12]->status = 0xA000
[42949402.550000] e100: eth0: e100_intr: stat_ack = 0x20
[42949402.550000] e100: eth0: e100_rx_indicate: status=0x0000
[42949402.550000] e100: eth0: e100_tx_clean: cb[13]->status = 0xA000
[42949403.630000] e100: eth0: e100_intr: stat_ack = 0x20
[42949403.630000] e100: eth0: e100_rx_indicate: status=0x0000
[42949403.630000] e100: eth0: e100_tx_clean: cb[14]->status = 0xA000
[42949404.630000] e100: eth0: e100_intr: stat_ack = 0x20
[42949404.630000] e100: eth0: e100_rx_indicate: status=0xA020
[42949404.630000] e100: eth0: e100_rx_indicate: status=0x0000
[42949404.630000] e100: eth0: e100_tx_clean: cb[15]->status = 0xA000
[42949404.630000] e100: eth0: e100_intr: stat_ack = 0x40
[42949404.630000] e100: eth0: e100_rx_indicate: status=0x0000
[42949405.000000] e100: eth0: e100_watchdog: right now = -26796
[42949405.000000] e100: eth0: e100_intr: stat_ack = 0x04
[42949405.010000] e100: eth0: e100_update_stats: exec cuc_dump_reset failed
[42949405.010000] e100: eth0: e100_rx_indicate: status=0x0000
[42949407.000000] e100: eth0: e100_watchdog: right now = -26596
[42949407.000000] e100: eth0: e100_intr: stat_ack = 0x04
[42949407.010000] e100: eth0: e100_update_stats: exec cuc_dump_reset failed
[42949407.010000] e100: eth0: e100_rx_indicate: status=0x0000

# ethtool -S eth0
NIC statistics:
      rx_packets: 1
      tx_packets: 4
      rx_bytes: 60
      tx_bytes: 168
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
      tx_deferred: 0
      tx_single_collisions: 0
      tx_multi_collisions: 0
      tx_flow_control_pause: 0
      rx_flow_control_pause: 0
      rx_flow_control_unsupported: 0
      tx_tco_packets: 0
      rx_tco_packets: 0


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php

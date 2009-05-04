From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH] igb: Record hardware RX overruns in net_stats
Date: Mon, 04 May 2009 13:06:46 +0200
Message-ID: <1241435206.8115.104.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com
To: "David S. Miller" <davem@davemloft.net>,
	jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:53177 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264AbZEDLGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 07:06:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hardware RX fifo overruns for the 82576 is stored in the
RNBC (Receive No Buffers Count) register.

I choose the store the RNBC value in net_stats.rx_fifo_errors.

Saving the stats in dev->net_stats makes it visible via
/proc/net/dev as "fifo", and thus viewable to ifconfig
as "overruns" and 'netstat -i' as "RX-OVR".

The Receive No Buffers Count (RNBC) can already be queried by
ethtool -S as "rx_no_buffer_count".

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 drivers/net/igb/igb_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)


diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 183235d..ef26e6a 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3596,6 +3596,7 @@ void igb_update_stats(struct igb_adapter *adapter)
 	adapter->net_stats.rx_crc_errors = adapter->stats.crcerrs;
 	adapter->net_stats.rx_frame_errors = adapter->stats.algnerrc;
 	adapter->net_stats.rx_missed_errors = adapter->stats.mpc;
+	adapter->net_stats.rx_fifo_errors = adapter->stats.rnbc;
 
 	/* Tx Errors */
 	adapter->net_stats.tx_errors = adapter->stats.ecol +



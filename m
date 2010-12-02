From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: emaclite: Omit private ndo_get_stats function
Date: Thu,  2 Dec 2010 18:20:39 +0100
Message-ID: <1291310439-5813-1-git-send-email-tklauser@distanz.ch>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:56718 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753133Ab0LBR2L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Dec 2010 12:28:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xemaclite_get_stats() just returns dev->stats so we can leave it out
alltogether and let dev_get_stats() do the job.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/xilinx_emaclite.c |   16 ----------------
 1 files changed, 0 insertions(+), 16 deletions(-)

diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emaclite.c
index 2de52d1..de6c308 100644
--- a/drivers/net/xilinx_emaclite.c
+++ b/drivers/net/xilinx_emaclite.c
@@ -1001,21 +1001,6 @@ static int xemaclite_close(struct net_device *dev)
 }
 
 /**
- * xemaclite_get_stats - Get the stats for the net_device
- * @dev:	Pointer to the network device
- *
- * This function returns the address of the 'net_device_stats' structure for the
- * given network device. This structure holds usage statistics for the network
- * device.
- *
- * Return:	Pointer to the net_device_stats structure.
- */
-static struct net_device_stats *xemaclite_get_stats(struct net_device *dev)
-{
-	return &dev->stats;
-}
-
-/**
  * xemaclite_send - Transmit a frame
  * @orig_skb:	Pointer to the socket buffer to be transmitted
  * @dev:	Pointer to the network device
@@ -1285,7 +1270,6 @@ static struct net_device_ops xemaclite_netdev_ops = {
 	.ndo_start_xmit		= xemaclite_send,
 	.ndo_set_mac_address	= xemaclite_set_mac_address,
 	.ndo_tx_timeout		= xemaclite_tx_timeout,
-	.ndo_get_stats		= xemaclite_get_stats,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = xemaclite_poll_controller,
 #endif
-- 
1.7.0.4


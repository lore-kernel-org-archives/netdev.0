From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 5/7] gianfar: gfar_process_frame returns void
Date: Thu, 14 Feb 2013 17:00:05 +0200
Message-ID: <1360854007-11094-6-git-send-email-claudiu.manoil@freescale.com>
References: <1360854007-11094-1-git-send-email-claudiu.manoil@freescale.com>
 <1360854007-11094-2-git-send-email-claudiu.manoil@freescale.com>
 <1360854007-11094-3-git-send-email-claudiu.manoil@freescale.com>
 <1360854007-11094-4-git-send-email-claudiu.manoil@freescale.com>
 <1360854007-11094-5-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe004.messaging.microsoft.com ([216.32.181.184]:48459
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754474Ab3BNPAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 10:00:19 -0500
In-Reply-To: <1360854007-11094-5-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No return code is expected from gfar_process_frame(), hence
change it to return void.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index af0f4d6..d70f74c 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -133,8 +133,8 @@ static void gfar_netpoll(struct net_device *dev);
 #endif
 int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit);
 static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue);
-static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
-			      int amount_pull, struct napi_struct *napi);
+static void gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
+			       int amount_pull, struct napi_struct *napi);
 void gfar_halt(struct net_device *dev);
 static void gfar_halt_nodisable(struct net_device *dev);
 void gfar_start(struct net_device *dev);
@@ -2692,8 +2692,8 @@ static inline void gfar_rx_checksum(struct sk_buff *skb, struct rxfcb *fcb)
 
 
 /* gfar_process_frame() -- handle one incoming packet if skb isn't NULL. */
-static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
-			      int amount_pull, struct napi_struct *napi)
+static void gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
+			       int amount_pull, struct napi_struct *napi)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct rxfcb *fcb = NULL;
@@ -2742,8 +2742,6 @@ static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 
 	if (unlikely(GRO_DROP == ret))
 		atomic64_inc(&priv->extra_stats.kernel_dropped);
-
-	return 0;
 }
 
 /* gfar_clean_rx_ring() -- Processes each frame in the rx ring
-- 
1.7.7.4

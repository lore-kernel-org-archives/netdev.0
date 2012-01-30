From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH V3 09/16] netback: nuke xenvif_receive_skb
Date: Mon, 30 Jan 2012 14:45:27 +0000
Message-ID: <1327934734-8908-10-git-send-email-wei.liu2@citrix.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ian.campbell@citrix.com, konrad.wilk@oracle.com,
	Wei Liu <wei.liu2@citrix.com>
To: netdev@vger.kernel.org, xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:45960 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753368Ab2A3Opp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 09:45:45 -0500
In-Reply-To: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace it with direct call to netif_receive_skb.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h    |    2 --
 drivers/net/xen-netback/interface.c |    5 -----
 drivers/net/xen-netback/netback.c   |    2 +-
 3 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 53141c7..28121f1 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -152,8 +152,6 @@ int xenvif_map_frontend_rings(struct xenvif *vif,
 
 /* Check for SKBs from frontend and schedule backend processing */
 void xenvif_check_rx_xenvif(struct xenvif *vif);
-/* Receive an SKB from the frontend */
-void xenvif_receive_skb(struct xenvif *vif, struct sk_buff *skb);
 
 /* Queue an SKB for transmission to the frontend */
 void xenvif_queue_tx_skb(struct xenvif *vif, struct sk_buff *skb);
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index fe37143..d7a7cd9 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -117,11 +117,6 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-void xenvif_receive_skb(struct xenvif *vif, struct sk_buff *skb)
-{
-	netif_receive_skb(skb);
-}
-
 void xenvif_notify_tx_completion(struct xenvif *vif)
 {
 	if (netif_queue_stopped(vif->dev) && xenvif_rx_schedulable(vif))
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 065cd65..a8d58a9 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1270,7 +1270,7 @@ static int xenvif_tx_submit(struct xenvif *vif,
 
 		work_done++;
 
-		xenvif_receive_skb(vif, skb);
+		netif_receive_skb(skb);
 	}
 
 	return work_done;
-- 
1.7.2.5

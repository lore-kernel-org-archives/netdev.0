From: Dmitry Torokhov <dtor@insightbb.com>
Subject: [patch 1/3] atmel: save on array initialization
Date: Sun, 08 Oct 2006 00:14:28 -0400
Message-ID: <20061008041551.988552023.dtor@insightbb.com>
References: <20061008041427.216886195.dtor@insightbb.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.insightbb.com ([74.128.0.19]:29491 "EHLO
	asav08.insightbb.com") by vger.kernel.org with ESMTP
	id S1750780AbWJHERi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Oct 2006 00:17:38 -0400
To: linville@tuxdriver.com
Content-Disposition: inline; filename=atmel-use-static-array.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NET: atmel - do not initialize array over and over again

Signed-off-by: Dmitry Torokhov <dtor@mail.ru>
---

 drivers/net/wireless/atmel.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: work/drivers/net/wireless/atmel.c
===================================================================
--- work.orig/drivers/net/wireless/atmel.c
+++ work/drivers/net/wireless/atmel.c
@@ -784,11 +784,11 @@ static void tx_update_descriptor(struct 
 
 static int start_tx(struct sk_buff *skb, struct net_device *dev)
 {
+	static const u8 SNAP_RFC1024[6] = { 0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00 };
 	struct atmel_private *priv = netdev_priv(dev);
 	struct ieee80211_hdr_4addr header;
 	unsigned long flags;
 	u16 buff, frame_ctl, len = (ETH_ZLEN < skb->len) ? skb->len : ETH_ZLEN;
-	u8 SNAP_RFC1024[6] = {0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00};
 
 	if (priv->card && priv->present_callback &&
 	    !(*priv->present_callback)(priv->card)) {

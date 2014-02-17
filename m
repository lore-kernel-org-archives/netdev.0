From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next v2 3/6] gianfar: Remove useless HAS_PADDING device flag
Date: Mon, 17 Feb 2014 12:53:16 +0200
Message-ID: <1392634399-5456-4-git-send-email-claudiu.manoil@freescale.com>
References: <1392634399-5456-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe003.messaging.microsoft.com ([207.46.163.26]:48644
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752107AbaBQKxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 05:53:48 -0500
In-Reply-To: <1392634399-5456-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RCTRL updates of the FSL_GIANFAR_DEV_HAS_PADDING device
flag get overriden by the FSL_GIANFAR_DEV_HAS_TIMER flag
settings, which impose a Rx padding alignment of 8 bytes.
As all the eTSEC devices that set HAS_PADDING also set the
HAS_TIMER flag, the HAS_PADDING flag is now obsolete.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 15 +++------------
 drivers/net/ethernet/freescale/gianfar.h |  1 -
 2 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 9b12201..987f323 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -375,13 +375,6 @@ static void gfar_init_mac(struct net_device *ndev)
 		rctrl |= RCTRL_PADDING(priv->padding);
 	}
 
-	/* Insert receive time stamps into padding alignment bytes */
-	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER) {
-		rctrl &= ~RCTRL_PAL_MASK;
-		rctrl |= RCTRL_PADDING(8);
-		priv->padding = 8;
-	}
-
 	/* Enable HW time stamping if requested from user space */
 	if (priv->hwts_rx_en) {
 		rctrl |= RCTRL_PRSDEP_INIT | RCTRL_TS_ENABLE;
@@ -770,7 +763,6 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 				     FSL_GIANFAR_DEV_HAS_COALESCE |
 				     FSL_GIANFAR_DEV_HAS_RMON |
 				     FSL_GIANFAR_DEV_HAS_MULTI_INTR |
-				     FSL_GIANFAR_DEV_HAS_PADDING |
 				     FSL_GIANFAR_DEV_HAS_CSUM |
 				     FSL_GIANFAR_DEV_HAS_VLAN |
 				     FSL_GIANFAR_DEV_HAS_MAGIC_PACKET |
@@ -1168,10 +1160,9 @@ static int gfar_probe(struct platform_device *ofdev)
 
 	gfar_init_addr_hash_table(priv);
 
-	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_PADDING)
-		priv->padding = DEFAULT_PADDING;
-	else
-		priv->padding = 0;
+	/* Insert receive time stamps into padding alignment bytes */
+	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER)
+		priv->padding = 8;
 
 	if (dev->features & NETIF_F_IP_CSUM ||
 	    priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER)
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index de6e4f6..53e3466 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -880,7 +880,6 @@ struct gfar {
 #define FSL_GIANFAR_DEV_HAS_CSUM		0x00000010
 #define FSL_GIANFAR_DEV_HAS_VLAN		0x00000020
 #define FSL_GIANFAR_DEV_HAS_EXTENDED_HASH	0x00000040
-#define FSL_GIANFAR_DEV_HAS_PADDING		0x00000080
 #define FSL_GIANFAR_DEV_HAS_MAGIC_PACKET	0x00000100
 #define FSL_GIANFAR_DEV_HAS_BD_STASHING		0x00000200
 #define FSL_GIANFAR_DEV_HAS_BUF_STASHING	0x00000400
-- 
1.7.11.7

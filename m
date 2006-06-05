From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.18 3/3] tg3: Add tg3_netif_stop() in vlan funtions
Date: Mon, 05 Jun 2006 12:47:38 -0700
Message-ID: <1149536858.13155.8.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:46860 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1751021AbWFEVbn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 17:31:43 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add tg3_netif_stop() when changing the vlgrp (vlan group) pointer. It
is necessary to quiesce the device before changing that pointer.

Update version to 3.60

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index f085890..d97cded 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -69,8 +69,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.59"
-#define DRV_MODULE_RELDATE	"May 26, 2006"
+#define DRV_MODULE_VERSION	"3.60"
+#define DRV_MODULE_RELDATE	"June 5, 2006"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
@@ -8735,6 +8735,9 @@ static void tg3_vlan_rx_register(struct 
 {
 	struct tg3 *tp = netdev_priv(dev);
 
+	if (netif_running(dev))
+		tg3_netif_stop(tp);
+
 	tg3_full_lock(tp, 0);
 
 	tp->vlgrp = grp;
@@ -8743,16 +8746,25 @@ static void tg3_vlan_rx_register(struct 
 	__tg3_set_rx_mode(dev);
 
 	tg3_full_unlock(tp);
+
+	if (netif_running(dev))
+		tg3_netif_start(tp);
 }
 
 static void tg3_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 {
 	struct tg3 *tp = netdev_priv(dev);
 
+	if (netif_running(dev))
+		tg3_netif_stop(tp);
+
 	tg3_full_lock(tp, 0);
 	if (tp->vlgrp)
 		tp->vlgrp->vlan_devices[vid] = NULL;
 	tg3_full_unlock(tp);
+
+	if (netif_running(dev))
+		tg3_netif_start(tp);
 }
 #endif
 



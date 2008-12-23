From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] ucc_geth: Eliminate the need for forward references
Date: Tue, 23 Dec 2008 19:59:25 +0300
Message-ID: <20081223165925.GA19473@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Cc: David Miller <davem@davemloft.net>, Li Yang <leoli@freescale.com>,
	Timur Tabi <timur@freescale.com>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:46166 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751129AbYLWQ73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 11:59:29 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch simply reorders some functions to eliminate the need for
forward references. No other changes than that.

Suggested-by: Timur Tabi <timur@freescale.com>
Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/ucc_geth.c |   81 +++++++++++++++++++++++-------------------------
 1 files changed, 39 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 6c2d074..764d421 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3072,48 +3072,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	return 0;
 }
 
-static int ucc_geth_close(struct net_device *dev);
-static int ucc_geth_open(struct net_device *dev);
-
-/* Reopen device. This will reset the MAC and PHY. */
-static void ucc_geth_timeout_work(struct work_struct *work)
-{
-	struct ucc_geth_private *ugeth;
-	struct net_device *dev;
-
-	ugeth = container_of(work, struct ucc_geth_private, timeout_work);
-	dev = ugeth->dev;
-
-	ugeth_vdbg("%s: IN", __func__);
-
-	dev->stats.tx_errors++;
-
-	ugeth_dump_regs(ugeth);
-
-	if (dev->flags & IFF_UP) {
-		/*
-		 * Must reset MAC *and* PHY. This is done by reopening
-		 * the device.
-		 */
-		ucc_geth_close(dev);
-		ucc_geth_open(dev);
-	}
-
-	netif_tx_schedule_all(dev);
-}
-
-/*
- * ucc_geth_timeout gets called when a packet has not been
- * transmitted after a set amount of time.
- */
-static void ucc_geth_timeout(struct net_device *dev)
-{
-	struct ucc_geth_private *ugeth = netdev_priv(dev);
-
-	netif_carrier_off(dev);
-	schedule_work(&ugeth->timeout_work);
-}
-
 /* This is called by the kernel when a frame is ready for transmission. */
 /* It is pointed to by the dev->hard_start_xmit function pointer */
 static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -3526,6 +3484,45 @@ static int ucc_geth_close(struct net_device *dev)
 	return 0;
 }
 
+/* Reopen device. This will reset the MAC and PHY. */
+static void ucc_geth_timeout_work(struct work_struct *work)
+{
+	struct ucc_geth_private *ugeth;
+	struct net_device *dev;
+
+	ugeth = container_of(work, struct ucc_geth_private, timeout_work);
+	dev = ugeth->dev;
+
+	ugeth_vdbg("%s: IN", __func__);
+
+	dev->stats.tx_errors++;
+
+	ugeth_dump_regs(ugeth);
+
+	if (dev->flags & IFF_UP) {
+		/*
+		 * Must reset MAC *and* PHY. This is done by reopening
+		 * the device.
+		 */
+		ucc_geth_close(dev);
+		ucc_geth_open(dev);
+	}
+
+	netif_tx_schedule_all(dev);
+}
+
+/*
+ * ucc_geth_timeout gets called when a packet has not been
+ * transmitted after a set amount of time.
+ */
+static void ucc_geth_timeout(struct net_device *dev)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(dev);
+
+	netif_carrier_off(dev);
+	schedule_work(&ugeth->timeout_work);
+}
+
 static phy_interface_t to_phy_interface(const char *phy_connection_type)
 {
 	if (strcasecmp(phy_connection_type, "mii") == 0)
-- 
1.5.6.5

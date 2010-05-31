From: Anatolij Gustschin <agust@denx.de>
Subject: [PATCH] can: mpc5xxx_can.c: Fix build failure
Date: Mon, 31 May 2010 18:31:39 +0200
Message-ID: <1275323499-15543-1-git-send-email-agust@denx.de>
Cc: "David S. Miller" <davem@davemloft.net>,
	Anatolij Gustschin <agust@denx.de>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Grant Likely <grant.likely@secretlab.ca>
To: netdev@vger.kernel.org, socketcan-core@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:38414 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194Ab0EaQb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 12:31:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes build error caused by the OF device_node pointer
being moved into struct device.

Signed-off-by: Anatolij Gustschin <agust@denx.de>
Cc: Wolfgang Grandegger <wg@grandegger.com>
Cc: Grant Likely <grant.likely@secretlab.ca>
---
 drivers/net/can/mscan/mpc5xxx_can.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/mscan/mpc5xxx_can.c
index 8af8442..f48deaf 100644
--- a/drivers/net/can/mscan/mpc5xxx_can.c
+++ b/drivers/net/can/mscan/mpc5xxx_can.c
@@ -152,7 +152,7 @@ static u32 __devinit mpc512x_can_get_clock(struct of_device *ofdev,
 	}
 
 	/* Determine the MSCAN device index from the physical address */
-	pval = of_get_property(ofdev->node, "reg", &plen);
+	pval = of_get_property(ofdev->dev.of_node, "reg", &plen);
 	BUG_ON(!pval || plen < sizeof(*pval));
 	clockidx = (*pval & 0x80) ? 1 : 0;
 	if (*pval & 0x2000)
@@ -168,11 +168,11 @@ static u32 __devinit mpc512x_can_get_clock(struct of_device *ofdev,
 	 */
 	if (clock_name && !strcmp(clock_name, "ip")) {
 		*mscan_clksrc = MSCAN_CLKSRC_IPS;
-		freq = mpc5xxx_get_bus_frequency(ofdev->node);
+		freq = mpc5xxx_get_bus_frequency(ofdev->dev.of_node);
 	} else {
 		*mscan_clksrc = MSCAN_CLKSRC_BUS;
 
-		pval = of_get_property(ofdev->node,
+		pval = of_get_property(ofdev->dev.of_node,
 				       "fsl,mscan-clock-divider", &plen);
 		if (pval && plen == sizeof(*pval))
 			clockdiv = *pval;
@@ -251,7 +251,7 @@ static int __devinit mpc5xxx_can_probe(struct of_device *ofdev,
 				       const struct of_device_id *id)
 {
 	struct mpc5xxx_can_data *data = (struct mpc5xxx_can_data *)id->data;
-	struct device_node *np = ofdev->node;
+	struct device_node *np = ofdev->dev.of_node;
 	struct net_device *dev;
 	struct mscan_priv *priv;
 	void __iomem *base;
-- 
1.7.0.4


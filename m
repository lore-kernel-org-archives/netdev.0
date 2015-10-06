From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH RFC v1 5/7] net/faraday: Replace use_nc_si with use_ncsi
Date: Tue,  6 Oct 2015 14:09:47 +1100
Message-ID: <1444100989-3437-6-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1444100989-3437-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, davem@davemloft.net,
	Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp01.au.ibm.com ([202.81.31.143]:51545 "EHLO
	e23smtp01.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751517AbbJFDu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 23:50:57 -0400
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Tue, 6 Oct 2015 13:50:54 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 87DFA2BB0052
	for <netdev@vger.kernel.org>; Tue,  6 Oct 2015 14:50:51 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t963oiwu50921536
	for <netdev@vger.kernel.org>; Tue, 6 Oct 2015 14:50:53 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t963oIuV029611
	for <netdev@vger.kernel.org>; Tue, 6 Oct 2015 14:50:19 +1100
In-Reply-To: <1444100989-3437-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch replaces variable name "use_nc_si" with "use_ncsi". No
function changed.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 08e0336..778bee8 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -75,7 +75,7 @@ struct ftgmac100 {
 	struct phy_device *phydev;
 	int old_speed;
 
-	bool use_nc_si;
+	bool use_ncsi;
 };
 
 static int ftgmac100_alloc_rx_page(struct ftgmac100 *priv,
@@ -1150,11 +1150,11 @@ static int ftgmac100_open(struct net_device *netdev)
 		goto err_hw;
 
 	ftgmac100_init_hw(priv);
-	ftgmac100_start_hw(priv, priv->use_nc_si ? 100 : 10);
+	ftgmac100_start_hw(priv, priv->use_ncsi ? 100 : 10);
 
 	if (priv->phydev)
 		phy_start(priv->phydev);
-	else if (priv->use_nc_si)
+	else if (priv->use_ncsi)
 		netif_carrier_on(priv->netdev);
 
 	napi_enable(&priv->napi);
@@ -1275,7 +1275,7 @@ err_alloc_mdiobus:
 
 static void ftgmac100_destroy_mdio(struct ftgmac100 *priv)
 {
-	if (!priv->use_nc_si)
+	if (!priv->use_ncsi)
 		return;
 	phy_disconnect(priv->phydev);
 	mdiobus_unregister(priv->mii_bus);
@@ -1359,9 +1359,9 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	/* Check for NC-SI mode */
 	if (pdev->dev.of_node &&
 	    of_get_property(pdev->dev.of_node, "use-nc-si", NULL))
-		priv->use_nc_si = true;
+		priv->use_ncsi = true;
 	else
-		priv->use_nc_si = false;
+		priv->use_ncsi = false;
 
 	/* If we use NC-SI, we need to set that up, which isn't implemented yet
 	 * so we pray things were setup by the bootloader and just mark our link
@@ -1370,7 +1370,7 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	 * Eventually, we'll have a proper NC-SI stack as a helper we can
 	 * instanciate
 	 */
-	if (priv->use_nc_si) {
+	if (priv->use_ncsi) {
 		/* XXX */
 		priv->phydev = NULL;
 		dev_info(&pdev->dev, "Using NC-SI interface\n");
-- 
2.1.0

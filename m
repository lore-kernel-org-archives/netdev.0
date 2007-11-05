From: Roel Kluin <12o3l@tiscali.nl>
Subject: [PATCH] Fix incorrect usage of strncat in bdx_get_drvinfo(); drivers/net/tehuti.c
Date: Mon, 05 Nov 2007 21:43:39 +0100
Message-ID: <472F807B.3050901@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out0.tiscali.nl ([195.241.79.175]:58546 "EHLO
	smtp-out0.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753324AbXKEUnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 15:43:42 -0500
Received: from [82.171.216.234] (helo=[192.168.1.2])
	by smtp-out0.tiscali.nl with esmtp (Tiscali http://www.tiscali.nl)
	id 1Ip8nN-0006Te-9J
	for <netdev@vger.kernel.org>; Mon, 05 Nov 2007 21:43:41 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix incorrect length for strncat by replacing it with strlcat

Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 4e1b84e..21230c9 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -2168,10 +2168,10 @@ bdx_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
 {
 	struct bdx_priv *priv = netdev->priv;
 
-	strncat(drvinfo->driver, BDX_DRV_NAME, sizeof(drvinfo->driver));
-	strncat(drvinfo->version, BDX_DRV_VERSION, sizeof(drvinfo->version));
-	strncat(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
-	strncat(drvinfo->bus_info, pci_name(priv->pdev),
+	strlcat(drvinfo->driver, BDX_DRV_NAME, sizeof(drvinfo->driver));
+	strlcat(drvinfo->version, BDX_DRV_VERSION, sizeof(drvinfo->version));
+	strlcat(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
+	strlcat(drvinfo->bus_info, pci_name(priv->pdev),
 		sizeof(drvinfo->bus_info));
 
 	drvinfo->n_stats = ((priv->stats_flag) ?

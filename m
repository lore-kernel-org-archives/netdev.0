From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 5/7] stmmac: get the descriptor structure from platform
Date: Wed, 14 Apr 2010 08:21:15 +0200
Message-ID: <1271226077-25882-5-git-send-email-peppe.cavallaro@st.com>
References: <1271226077-25882-1-git-send-email-peppe.cavallaro@st.com>
 <1271226077-25882-2-git-send-email-peppe.cavallaro@st.com>
 <1271226077-25882-3-git-send-email-peppe.cavallaro@st.com>
 <1271226077-25882-4-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:53897 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753790Ab0DNGVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 02:21:44 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 2565712B
	for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 06:21:42 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id CCC8911BC
	for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 06:21:41 +0000 (GMT)
In-Reply-To: <1271226077-25882-4-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Output for chip that uses the Enhanced descriptors:
[snip]
STMMAC driver:
	platform registration... done!
	DWMAC1000 - user ID: 0x10, Synopsys ID: 0x33
	Enhanced descriptor structure
	no valid MAC address;please, use ifconfig or nwhwconfig!
	eth0 - (dev. name: stmmaceth - id: 0, IRQ #134
	IO base addr: 0xfd110000)
STMMAC MII Bus: probed
[snip]

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac.h      |    1 +
 drivers/net/stmmac/stmmac_main.c |   12 ++++++++----
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index 55b9aca..0d776bc 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -93,6 +93,7 @@ struct stmmac_priv {
 #ifdef STMMAC_VLAN_TAG_USED
 	struct vlan_group *vlgrp;
 #endif
+	int enh_desc;
 };
 
 #ifdef CONFIG_STM_DRIVERS
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index dafe4dc..78d1a8b 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1582,13 +1582,16 @@ static int stmmac_mac_device_setup(struct net_device *dev)
 
 	struct mac_device_info *device;
 
-	if (priv->is_gmac) {
+	if (priv->is_gmac)
 		device = dwmac1000_setup(ioaddr);
-		device->desc = &enh_desc_ops;
-	} else {
+	else
 		device = dwmac100_setup(ioaddr);
+
+	if (priv->enh_desc) {
+		device->desc = &enh_desc_ops;
+		pr_info("\tEnhanced descriptor structure\n");
+	} else
 		device->desc = &ndesc_ops;
-	}
 
 	if (!device)
 		return -ENOMEM;
@@ -1730,6 +1733,7 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	priv->bus_id = plat_dat->bus_id;
 	priv->pbl = plat_dat->pbl;	/* TLI */
 	priv->is_gmac = plat_dat->has_gmac;	/* GMAC is on board */
+	priv->enh_desc = plat_dat->enh_desc;
 
 	platform_set_drvdata(pdev, ndev);
 
-- 
1.6.0.4


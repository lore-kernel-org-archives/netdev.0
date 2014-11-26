From: Huacai Chen <chenhc@lemote.com>
Subject: [PATCH] stmmac: platform: fix default values of the filter bins setting
Date: Wed, 26 Nov 2014 10:38:06 +0800
Message-ID: <1416969486-9047-1-git-send-email-chenhc@lemote.com>
Cc: Vince Bridgers <vbridgers2013@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Huacai Chen <chenhc@lemote.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:43702 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149AbaKZCiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 21:38:21 -0500
Received: by mail-pd0-f169.google.com with SMTP id fp1so1791648pdb.28
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 18:38:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 3b57de958e2a brought the support for a different amount of
the filter bins, but didn't update the platform driver that without
CONFIG_OF.

Fixes: 3b57de958e2a (net: stmmac: Support devicetree configs for mcast
and ucast filter entries)

Signed-off-by: Huacai Chen <chenhc@lemote.com>
---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index db56fa7..5b0da39 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -177,12 +177,6 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 	 */
 	plat->maxmtu = JUMBO_LEN;
 
-	/* Set default value for multicast hash bins */
-	plat->multicast_filter_bins = HASH_TABLE_SIZE;
-
-	/* Set default value for unicast filter entries */
-	plat->unicast_filter_entries = 1;
-
 	/*
 	 * Currently only the properties needed on SPEAr600
 	 * are provided. All other properties should be added
@@ -270,6 +264,13 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 		return PTR_ERR(addr);
 
 	plat_dat = dev_get_platdata(&pdev->dev);
+
+	/* Set default value for multicast hash bins */
+	plat_dat->multicast_filter_bins = HASH_TABLE_SIZE;
+
+	/* Set default value for unicast filter entries */
+	plat_dat->unicast_filter_entries = 1;
+
 	if (pdev->dev.of_node) {
 		if (!plat_dat)
 			plat_dat = devm_kzalloc(&pdev->dev,
-- 
1.7.7.3

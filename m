From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git)] stmmac: platform: fix FIXED_PHY support.
Date: Tue, 14 Oct 2014 08:11:54 +0200
Message-ID: <1413267114-24043-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:47676 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753373AbaJNGQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 02:16:35 -0400
Received: from pps.filterd (m0046660.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id s9E6CcqH004401
	for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 08:16:33 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx08-00178001.pphosted.com with ESMTP id 1q0bw2cx5e-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 08:16:33 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 8A1C831
	for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 06:16:08 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id B5D6416A1E
	for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 06:16:30 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On several STi platforms: e.g. stihxxx-b2120 an Ethernet switch is
embedded and connected to the stmmac via RGMII mode. So this is managed
by using the FIXED_PHY. In that case, the support in the platform needs
to be fixed to allow the stmmac to dialog with the switch via fixed-link
by using phy_bus_name property.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 6521717..4894500 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -160,11 +160,16 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 	if (of_property_read_u32(np, "snps,phy-addr", &plat->phy_addr) == 0)
 		dev_warn(&pdev->dev, "snps,phy-addr property is deprecated\n");
 
-	plat->mdio_bus_data = devm_kzalloc(&pdev->dev,
-					   sizeof(struct stmmac_mdio_bus_data),
-					   GFP_KERNEL);
-
-	plat->force_sf_dma_mode = of_property_read_bool(np, "snps,force_sf_dma_mode");
+	if (plat->phy_bus_name)
+		plat->mdio_bus_data = NULL;
+	else
+		plat->mdio_bus_data =
+			devm_kzalloc(&pdev->dev,
+				     sizeof(struct stmmac_mdio_bus_data),
+				     GFP_KERNEL);
+
+	plat->force_sf_dma_mode =
+		of_property_read_bool(np, "snps,force_sf_dma_mode");
 
 	/* Set the maxmtu to a default of JUMBO_LEN in case the
 	 * parameter is not present in the device tree.
-- 
1.7.4.4

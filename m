From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 12/17] stmmac: dwmac-sti: use custom of match structure
Date: Wed, 29 Jul 2015 00:08:59 +0200
Message-ID: <1438121344-5304-13-git-send-email-manabian@gmail.com>
References: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org,
	kernel@stlinux.com
To: peppe.cavallaro@st.com, srinivas.kandagatla@gmail.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f68.google.com ([209.85.215.68]:36447 "EHLO
	mail-la0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167AbbG1WJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 18:09:34 -0400
Received: by lafd3 with SMTP id d3so5850231laf.3
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 15:09:33 -0700 (PDT)
In-Reply-To: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create a new private structure for OF match data in the
dwmac-sti driver. This enables us to eventually drop the
common OF match data structure which contains a lot of
unused fields.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
index 8a977fde1a46..83c501edb688 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
@@ -131,6 +131,11 @@ struct sti_dwmac {
 	u32 speed;
 };
 
+struct sti_dwmac_of_data {
+	void (*fix_mac_speed)(void *priv, unsigned int speed);
+	int (*init)(struct platform_device *pdev, void *priv);
+};
+
 static u32 phy_intf_sels[] = {
 	[PHY_INTERFACE_MODE_MII] = ETH_PHY_SEL_MII,
 	[PHY_INTERFACE_MODE_GMII] = ETH_PHY_SEL_GMII,
@@ -338,7 +343,7 @@ static int sti_dwmac_parse_data(struct sti_dwmac *dwmac,
 static int sti_dwmac_probe(struct platform_device *pdev)
 {
 	struct plat_stmmacenet_data *plat_dat;
-	const struct stmmac_of_data *data;
+	const struct sti_dwmac_of_data *data;
 	struct stmmac_resources stmmac_res;
 	struct sti_dwmac *dwmac;
 	int ret;
@@ -379,12 +384,12 @@ static int sti_dwmac_probe(struct platform_device *pdev)
 	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
 }
 
-static const struct stmmac_of_data stih4xx_dwmac_data = {
+static const struct sti_dwmac_of_data stih4xx_dwmac_data = {
 	.fix_mac_speed = stih4xx_fix_retime_src,
 	.init = stix4xx_init,
 };
 
-static const struct stmmac_of_data stid127_dwmac_data = {
+static const struct sti_dwmac_of_data stid127_dwmac_data = {
 	.fix_mac_speed = stid127_fix_retime_src,
 	.init = stid127_init,
 };
-- 
1.8.0

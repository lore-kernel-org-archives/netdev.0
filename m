From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 1/8] stmmac: use of_device_get_match_data to retrieve of match data
Date: Fri, 17 Jul 2015 00:26:05 +0200
Message-ID: <1437085572-11371-2-git-send-email-manabian@gmail.com>
References: <1437085572-11371-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org
To: peppe.cavallaro@st.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:35886 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751586AbbGPW0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 18:26:35 -0400
Received: by lagw2 with SMTP id w2so51607753lag.3
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 15:26:34 -0700 (PDT)
In-Reply-To: <1437085572-11371-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By using of_device_get_match_data() the code that retrieve
match data can be simplified quite a bit.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index f3918c7e7eeb..89e40ddc0391 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -109,13 +109,11 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 				  const char **mac)
 {
 	struct device_node *np = pdev->dev.of_node;
+	const struct stmmac_of_data *data;
 	struct stmmac_dma_cfg *dma_cfg;
-	const struct of_device_id *device;
-	struct device *dev = &pdev->dev;
 
-	device = of_match_device(dev->driver->of_match_table, dev);
-	if (device->data) {
-		const struct stmmac_of_data *data = device->data;
+	data = of_device_get_match_data(&pdev->dev);
+	if (data) {
 		plat->has_gmac = data->has_gmac;
 		plat->enh_desc = data->enh_desc;
 		plat->tx_coe = data->tx_coe;
-- 
1.8.0

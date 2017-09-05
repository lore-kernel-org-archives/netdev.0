From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH 2/3] drivers: net: xgene: Configure tx/rx delay for ACPI
Date: Tue,  5 Sep 2017 11:16:31 -0700
Message-ID: <1504635392-19089-3-git-send-email-isubramanian@apm.com>
References: <1504635392-19089-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, dnelson@redhat.com,
        patches@apm.com, Quan Nguyen <qnguyen@apm.com>,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:37014 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752681AbdIESQw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 14:16:52 -0400
Received: by mail-pg0-f45.google.com with SMTP id d8so10797959pgt.4
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 11:16:51 -0700 (PDT)
In-Reply-To: <1504635392-19089-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quan Nguyen <qnguyen@apm.com>

This patch fixes configuring tx/rx delay values for ACPI.

Signed-off-by: Quan Nguyen <qnguyen@apm.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index e45b587..3188f55 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -468,7 +468,6 @@ static void xgene_enet_configure_clock(struct xgene_enet_pdata *pdata)
 
 static void xgene_gmac_set_speed(struct xgene_enet_pdata *pdata)
 {
-	struct device *dev = &pdata->pdev->dev;
 	u32 icm0, icm2, mc2;
 	u32 intf_ctl, rgmii, value;
 
@@ -500,10 +499,8 @@ static void xgene_gmac_set_speed(struct xgene_enet_pdata *pdata)
 		intf_ctl |= ENET_GHD_MODE;
 		CFG_MACMODE_SET(&icm0, 2);
 		CFG_WAITASYNCRD_SET(&icm2, 0);
-		if (dev->of_node) {
-			CFG_TXCLK_MUXSEL0_SET(&rgmii, pdata->tx_delay);
-			CFG_RXCLK_MUXSEL0_SET(&rgmii, pdata->rx_delay);
-		}
+		CFG_TXCLK_MUXSEL0_SET(&rgmii, pdata->tx_delay);
+		CFG_RXCLK_MUXSEL0_SET(&rgmii, pdata->rx_delay);
 		rgmii |= CFG_SPEED_1250;
 
 		xgene_enet_rd_csr(pdata, DEBUG_REG_ADDR, &value);
-- 
2.7.4

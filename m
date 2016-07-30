From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 06/10] drivers: net: xgene: Change port init sequence
Date: Fri, 29 Jul 2016 17:33:59 -0700
Message-ID: <1469838843-19943-7-git-send-email-isubramanian@apm.com>
References: <1469838843-19943-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	linux@armlinux.org.uk, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34605 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753561AbcG3Ada (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 20:33:30 -0400
Received: by mail-pf0-f179.google.com with SMTP id p64so37120662pfb.1
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2016 17:33:30 -0700 (PDT)
In-Reply-To: <1469838843-19943-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch rearranges the port initialization sequence as recommended by
hardware specification.  This patch also removes, mac_init() call from
xgene_enet_link_state(), as it was not required.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Fushen Chen <fchen@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
index 9c6ad0d..d53c053 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
@@ -216,12 +216,12 @@ static void xgene_xgmac_init(struct xgene_enet_pdata *pdata)
 	data |= CFG_RSIF_FPBUFF_TIMEOUT_EN;
 	xgene_enet_wr_csr(pdata, XG_RSIF_CONFIG_REG_ADDR, data);
 
-	xgene_enet_wr_csr(pdata, XG_CFG_BYPASS_ADDR, RESUME_TX);
-	xgene_enet_wr_csr(pdata, XGENET_RX_DV_GATE_REG_0_ADDR, 0);
 	xgene_enet_rd_csr(pdata, XG_ENET_SPARE_CFG_REG_ADDR, &data);
 	data |= BIT(12);
 	xgene_enet_wr_csr(pdata, XG_ENET_SPARE_CFG_REG_ADDR, data);
 	xgene_enet_wr_csr(pdata, XG_ENET_SPARE_CFG_REG_1_ADDR, 0x82);
+	xgene_enet_wr_csr(pdata, XGENET_RX_DV_GATE_REG_0_ADDR, 0);
+	xgene_enet_wr_csr(pdata, XG_CFG_BYPASS_ADDR, RESUME_TX);
 }
 
 static void xgene_xgmac_rx_enable(struct xgene_enet_pdata *pdata)
@@ -366,7 +366,6 @@ static void xgene_enet_link_state(struct work_struct *work)
 	if (link_status) {
 		if (!netif_carrier_ok(ndev)) {
 			netif_carrier_on(ndev);
-			xgene_xgmac_init(pdata);
 			xgene_xgmac_rx_enable(pdata);
 			xgene_xgmac_tx_enable(pdata);
 			netdev_info(ndev, "Link is Up - 10Gbps\n");
-- 
1.9.1

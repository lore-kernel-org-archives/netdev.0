From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 net-next 03/12] drivers: net: xgene: Use rgmii mdio mac access
Date: Wed, 10 May 2017 13:45:01 -0700
Message-ID: <1494449110-23785-4-git-send-email-isubramanian@apm.com>
References: <1494449110-23785-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Quan Nguyen <qnguyen@apm.com>,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:34319 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753155AbdEJUmY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 16:42:24 -0400
Received: by mail-io0-f172.google.com with SMTP id k91so9466146ioi.1
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 13:42:24 -0700 (PDT)
In-Reply-To: <1494449110-23785-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quan Nguyen <qnguyen@apm.com>

This patch switches to use rgmii mdio mac access routines if available,
as they share the same HW.

Signed-off-by: Quan Nguyen <qnguyen@apm.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 2050c58..47c5b75 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -277,6 +277,13 @@ void xgene_enet_wr_mac(struct xgene_enet_pdata *pdata, u32 wr_addr, u32 wr_data)
 	u8 wait = 10;
 	u32 done;
 
+	if (pdata->mdio_driver && ndev->phydev &&
+	    pdata->phy_mode == PHY_INTERFACE_MODE_RGMII) {
+		struct mii_bus *bus = ndev->phydev->mdio.bus;
+
+		return xgene_mdio_wr_mac(bus->priv, wr_addr, wr_data);
+	}
+
 	addr = pdata->mcx_mac_addr + MAC_ADDR_REG_OFFSET;
 	wr = pdata->mcx_mac_addr + MAC_WRITE_REG_OFFSET;
 	cmd = pdata->mcx_mac_addr + MAC_COMMAND_REG_OFFSET;
@@ -328,6 +335,13 @@ u32 xgene_enet_rd_mac(struct xgene_enet_pdata *pdata, u32 rd_addr)
 	u32 done, rd_data;
 	u8 wait = 10;
 
+	if (pdata->mdio_driver && pdata->ndev->phydev &&
+	    pdata->phy_mode == PHY_INTERFACE_MODE_RGMII) {
+		struct mii_bus *bus = pdata->ndev->phydev->mdio.bus;
+
+		return xgene_mdio_rd_mac(bus->priv, rd_addr);
+	}
+
 	addr = pdata->mcx_mac_addr + MAC_ADDR_REG_OFFSET;
 	rd = pdata->mcx_mac_addr + MAC_READ_REG_OFFSET;
 	cmd = pdata->mcx_mac_addr + MAC_COMMAND_REG_OFFSET;
-- 
1.9.1

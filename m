From: Peter Chen <peter.chen@nxp.com>
Subject: [PATCH 02/15] ethernet: apm: xgene: add missing of_node_put after calling of_parse_phandle
Date: Wed, 27 Jul 2016 10:20:35 +0800
Message-ID: <1469586048-15697-3-git-send-email-peter.chen@nxp.com>
References: <1469586048-15697-1-git-send-email-peter.chen@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <vbridger@opensource.altera.com>,
	<isubramanian@apm.com>, <kchudgar@apm.com>,
	<yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
	<thomas.petazzoni@free-electrons.com>,
	<sergei.shtylyov@cogentembedded.com>, <peppe.cavallaro@st.com>,
	<alexandre.torgue@st.com>, <mugunthanvnm@ti.com>,
	<tremyfr@gmail.com>, <wxt@rock-chips.com>, <arnd@arndb.de>,
	<david.daney@cavium.com>, <huangdaode@hisilicon.com>,
	<jszhang@marvell.com>, Peter Chen <peter.chen@nxp.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0045.outbound.protection.outlook.com ([104.47.38.45]:51747
	"EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756109AbcG0CoJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 22:44:09 -0400
In-Reply-To: <1469586048-15697-1-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_node_put needs to be called when the device node which is got
from of_parse_phandle has finished using.

Signed-off-by: Peter Chen <peter.chen@nxp.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 2f5638f..fb23408 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -758,6 +758,7 @@ static int xgene_enet_phy_connect(struct net_device *ndev)
 
 		phy_dev = of_phy_connect(ndev, phy_np, &xgene_enet_adjust_link,
 					 0, pdata->phy_mode);
+		of_node_put(phy_np);
 		if (!phy_dev) {
 			netdev_err(ndev, "Could not connect to PHY\n");
 			return -ENODEV;
-- 
1.9.1

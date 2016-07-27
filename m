From: Peter Chen <peter.chen@nxp.com>
Subject: [PATCH 15/15] ethernet: ti: davinci_emac: add missing of_node_put after calling of_parse_phandle
Date: Wed, 27 Jul 2016 10:20:48 +0800
Message-ID: <1469586048-15697-16-git-send-email-peter.chen@nxp.com>
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
Received: from mail-bn3nam01on0089.outbound.protection.outlook.com ([104.47.33.89]:53794
	"EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758789AbcG0CqN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 22:46:13 -0400
In-Reply-To: <1469586048-15697-1-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_node_put needs to be called when the device node which is got
from of_parse_phandle has finished using.

Signed-off-by: Peter Chen <peter.chen@nxp.com>
---
 drivers/net/ethernet/ti/davinci_emac.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index c6c5465..d8cb9d0 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1571,6 +1571,7 @@ static int emac_dev_open(struct net_device *ndev)
 	if (priv->phy_node) {
 		phydev = of_phy_connect(ndev, priv->phy_node,
 					&emac_adjust_link, 0, 0);
+		of_node_put(priv->phy_node);
 		if (!phydev) {
 			dev_err(emac_dev, "could not connect to phy %s\n",
 				priv->phy_node->full_name);
-- 
1.9.1

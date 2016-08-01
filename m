From: Peter Chen <peter.chen@nxp.com>
Subject: [PATCH v2 04/15] ethernet: aurora: nb8800: add missing of_node_put after calling of_parse_phandle
Date: Mon, 1 Aug 2016 15:02:32 +0800
Message-ID: <1470034963-30506-5-git-send-email-peter.chen@nxp.com>
References: <1470034963-30506-1-git-send-email-peter.chen@nxp.com>
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
Received: from mail-bl2nam02on0046.outbound.protection.outlook.com ([104.47.38.46]:7488
	"EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752107AbcHAHMD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2016 03:12:03 -0400
In-Reply-To: <1470034963-30506-1-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_node_put needs to be called when the device node which is got
from of_parse_phandle has finished using.

Signed-off-by: Peter Chen <peter.chen@nxp.com>
---
 drivers/net/ethernet/aurora/nb8800.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index 0d4ea92..b047fd6 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -1504,6 +1504,7 @@ static int nb8800_probe(struct platform_device *pdev)
 err_free_dma:
 	nb8800_dma_free(dev);
 err_free_bus:
+	of_node_put(priv->phy_node);
 	mdiobus_unregister(bus);
 err_disable_clk:
 	clk_disable_unprepare(priv->clk);
@@ -1519,6 +1520,7 @@ static int nb8800_remove(struct platform_device *pdev)
 	struct nb8800_priv *priv = netdev_priv(ndev);
 
 	unregister_netdev(ndev);
+	of_node_put(priv->phy_node);
 
 	mdiobus_unregister(priv->mii_bus);
 
-- 
1.9.1

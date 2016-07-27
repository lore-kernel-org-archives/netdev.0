From: Peter Chen <peter.chen@nxp.com>
Subject: [PATCH 04/15] ethernet: aurora: nb8800: add missing of_node_put after calling of_parse_phandle
Date: Wed, 27 Jul 2016 10:20:37 +0800
Message-ID: <1469586048-15697-5-git-send-email-peter.chen@nxp.com>
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
Received: from mail-co1nam03on0060.outbound.protection.outlook.com ([104.47.40.60]:46832
	"EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932320AbcG0Cox (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 22:44:53 -0400
In-Reply-To: <1469586048-15697-1-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_node_put needs to be called when the device node which is got
from of_parse_phandle has finished using.

Signed-off-by: Peter Chen <peter.chen@nxp.com>
---
 drivers/net/ethernet/aurora/nb8800.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index 0d4ea92..d15d96b 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -1006,6 +1006,7 @@ static int nb8800_stop(struct net_device *dev)
 
 	netif_stop_queue(dev);
 	napi_disable(&priv->napi);
+	of_node_put(priv->phy_node);
 
 	nb8800_dma_stop(dev);
 	nb8800_mac_rx(dev, false);
@@ -1504,6 +1505,7 @@ static int nb8800_probe(struct platform_device *pdev)
 err_free_dma:
 	nb8800_dma_free(dev);
 err_free_bus:
+	of_node_put(priv->phy_node);
 	mdiobus_unregister(bus);
 err_disable_clk:
 	clk_disable_unprepare(priv->clk);
-- 
1.9.1

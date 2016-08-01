From: Peter Chen <peter.chen@nxp.com>
Subject: [PATCH v2 07/15] ethernet: hisilicon: hns: hns_dsaf_main: add missing of_node_put after calling of_parse_phandle
Date: Mon, 1 Aug 2016 15:02:35 +0800
Message-ID: <1470034963-30506-8-git-send-email-peter.chen@nxp.com>
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
Received: from mail-dm3nam03on0047.outbound.protection.outlook.com ([104.47.41.47]:4416
	"EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750834AbcHAH2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2016 03:28:08 -0400
In-Reply-To: <1470034963-30506-1-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_node_put needs to be called when the device node which is got
from of_parse_phandle has finished using.

Signed-off-by: Peter Chen <peter.chen@nxp.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 2ef4277..afb5daa 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -51,7 +51,7 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 	const char *mode_str;
 	struct regmap *syscon;
 	struct resource *res;
-	struct device_node *np = dsaf_dev->dev->of_node;
+	struct device_node *np = dsaf_dev->dev->of_node, *np_temp;
 	struct platform_device *pdev = to_platform_device(dsaf_dev->dev);
 
 	if (dev_of_node(dsaf_dev->dev)) {
@@ -102,8 +102,9 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 		dsaf_dev->dsaf_tc_mode = HRD_DSAF_4TC_MODE;
 
 	if (dev_of_node(dsaf_dev->dev)) {
-		syscon = syscon_node_to_regmap(
-				of_parse_phandle(np, "subctrl-syscon", 0));
+		np_temp = of_parse_phandle(np, "subctrl-syscon", 0);
+		syscon = syscon_node_to_regmap(np_temp);
+		of_node_put(np_temp);
 		if (IS_ERR_OR_NULL(syscon)) {
 			res = platform_get_resource(pdev, IORESOURCE_MEM,
 						    res_idx++);
-- 
1.9.1

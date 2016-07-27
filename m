From: Peter Chen <peter.chen@nxp.com>
Subject: [PATCH 06/15] ethernet: hisilicon: hns: hns_dsaf_mac: add missing of_node_put after calling of_parse_phandle
Date: Wed, 27 Jul 2016 10:20:39 +0800
Message-ID: <1469586048-15697-7-git-send-email-peter.chen@nxp.com>
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
Received: from mail-co1nam03on0051.outbound.protection.outlook.com ([104.47.40.51]:37568
	"EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161399AbcG0Cpq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 22:45:46 -0400
In-Reply-To: <1469586048-15697-1-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_node_put needs to be called when the device node which is got
from of_parse_phandle has finished using.

Signed-off-by: Peter Chen <peter.chen@nxp.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 3fb87e2..18d72ea 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -786,6 +786,7 @@ static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
 		np = of_parse_phandle(mac_cb->dev->of_node, "phy-handle",
 				      mac_cb->mac_id);
 		mac_cb->phy_dev = of_phy_find_device(np);
+		of_node_put(np);
 		if (mac_cb->phy_dev) {
 			/* refcount is held by of_phy_find_device()
 			 * if the phy_dev is found
@@ -804,6 +805,7 @@ static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
 		np = of_parse_phandle(to_of_node(mac_cb->fw_port),
 				      "phy-handle", 0);
 		mac_cb->phy_dev = of_phy_find_device(np);
+		of_node_put(np);
 		if (mac_cb->phy_dev) {
 			/* refcount is held by of_phy_find_device()
 			 * if the phy_dev is found
@@ -813,9 +815,10 @@ static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
 				mac_cb->mac_id, np->name);
 		}
 
-		syscon = syscon_node_to_regmap(
-				of_parse_phandle(to_of_node(mac_cb->fw_port),
-						 "serdes-syscon", 0));
+		np = of_parse_phandle(to_of_node(mac_cb->fw_port),
+					"serdes-syscon", 0);
+		syscon = syscon_node_to_regmap(np);
+		of_node_put(np);
 		if (IS_ERR_OR_NULL(syscon)) {
 			dev_err(mac_cb->dev, "serdes-syscon is needed!\n");
 			return -EINVAL;
-- 
1.9.1

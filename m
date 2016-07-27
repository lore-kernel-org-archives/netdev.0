From: Peter Chen <peter.chen@nxp.com>
Subject: [PATCH 08/15] ethernet: marvell: mvneta: add missing of_node_put after calling of_parse_phandle
Date: Wed, 27 Jul 2016 10:20:41 +0800
Message-ID: <1469586048-15697-9-git-send-email-peter.chen@nxp.com>
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
Received: from mail-by2nam01on0079.outbound.protection.outlook.com ([104.47.34.79]:19328
	"EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161392AbcG0Cpq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 22:45:46 -0400
In-Reply-To: <1469586048-15697-1-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_node_put needs to be called when the device node which is got
from of_parse_phandle has finished using.

Signed-off-by: Peter Chen <peter.chen@nxp.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index f92018b..16aca9d 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -4113,6 +4113,7 @@ static int mvneta_probe(struct platform_device *pdev)
 	if (bm_node && bm_node->data) {
 		pp->bm_priv = bm_node->data;
 		err = mvneta_bm_port_init(pdev, pp);
+		of_node_put(bm_node);
 		if (err < 0) {
 			dev_info(&pdev->dev, "use SW buffer management\n");
 			pp->bm_priv = NULL;
-- 
1.9.1

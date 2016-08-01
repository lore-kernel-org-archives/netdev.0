From: Peter Chen <peter.chen@nxp.com>
Subject: [PATCH v2 08/15] ethernet: marvell: mvneta: add missing of_node_put after calling of_parse_phandle
Date: Mon, 1 Aug 2016 15:02:36 +0800
Message-ID: <1470034963-30506-9-git-send-email-peter.chen@nxp.com>
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
Received: from mail-sn1nam02on0077.outbound.protection.outlook.com ([104.47.36.77]:23456
	"EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752107AbcHAHMO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2016 03:12:14 -0400
In-Reply-To: <1470034963-30506-1-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_node_put needs to be called when the device node which is got
from of_parse_phandle has finished using.

Signed-off-by: Peter Chen <peter.chen@nxp.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index f92018b..d41c28d 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -4118,6 +4118,7 @@ static int mvneta_probe(struct platform_device *pdev)
 			pp->bm_priv = NULL;
 		}
 	}
+	of_node_put(bm_node);
 
 	err = mvneta_init(&pdev->dev, pp);
 	if (err < 0)
-- 
1.9.1

From: Peter Chen <peter.chen@nxp.com>
Subject: [PATCH 10/15] ethernet: marvell: pxa168_eth: add missing of_node_put after calling of_parse_phandle
Date: Wed, 27 Jul 2016 10:20:43 +0800
Message-ID: <1469586048-15697-11-git-send-email-peter.chen@nxp.com>
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
Received: from mail-bl2nam02on0055.outbound.protection.outlook.com ([104.47.38.55]:36649
	"EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161311AbcG0Co6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 22:44:58 -0400
In-Reply-To: <1469586048-15697-1-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_node_put needs to be called when the device node which is got
from of_parse_phandle has finished using.

Signed-off-by: Peter Chen <peter.chen@nxp.com>
---
 drivers/net/ethernet/marvell/pxa168_eth.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index aeeb2e7..5d5000c 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1506,6 +1506,7 @@ static int pxa168_eth_probe(struct platform_device *pdev)
 		}
 		of_property_read_u32(np, "reg", &pep->phy_addr);
 		pep->phy_intf = of_get_phy_mode(pdev->dev.of_node);
+		of_node_put(np);
 	}
 
 	/* Hardware supports only 3 ports */
-- 
1.9.1

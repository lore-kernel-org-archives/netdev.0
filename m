From: Peter Chen <peter.chen@nxp.com>
Subject: [PATCH 05/15] ethernet: cavium: octeon: add missing of_node_put after calling of_parse_phandle
Date: Wed, 27 Jul 2016 10:20:38 +0800
Message-ID: <1469586048-15697-6-git-send-email-peter.chen@nxp.com>
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
Received: from mail-bl2nam02on0064.outbound.protection.outlook.com ([104.47.38.64]:58325
	"EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161392AbcG0Cpg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 22:45:36 -0400
In-Reply-To: <1469586048-15697-1-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_node_put needs to be called when the device node which is got
from of_parse_phandle has finished using.

Signed-off-by: Peter Chen <peter.chen@nxp.com>
---
 drivers/net/ethernet/cavium/octeon/octeon_mgmt.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
index e8bc15b..5eb9d8c 100644
--- a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
@@ -960,6 +960,7 @@ static int octeon_mgmt_init_phy(struct net_device *netdev)
 	phydev = of_phy_connect(netdev, p->phy_np,
 				octeon_mgmt_adjust_link, 0,
 				PHY_INTERFACE_MODE_MII);
+	of_node_put(p->phy_np);
 
 	if (!phydev)
 		return -ENODEV;
-- 
1.9.1

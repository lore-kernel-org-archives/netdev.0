From: Peter Chen <peter.chen@nxp.com>
Subject: [PATCH v2 05/15] ethernet: cavium: octeon: add missing of_node_put after calling of_parse_phandle
Date: Mon, 1 Aug 2016 15:02:33 +0800
Message-ID: <1470034963-30506-6-git-send-email-peter.chen@nxp.com>
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
Received: from mail-co1nam03on0053.outbound.protection.outlook.com ([104.47.40.53]:64224
	"EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752107AbcHAHL5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2016 03:11:57 -0400
In-Reply-To: <1470034963-30506-1-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_node_put needs to be called when the device node which is got
from of_parse_phandle has finished using.

Signed-off-by: Peter Chen <peter.chen@nxp.com>
---
 drivers/net/ethernet/cavium/octeon/octeon_mgmt.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
index e8bc15b..4ab404f 100644
--- a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
@@ -1513,6 +1513,7 @@ static int octeon_mgmt_probe(struct platform_device *pdev)
 	return 0;
 
 err:
+	of_node_put(p->phy_np);
 	free_netdev(netdev);
 	return result;
 }
@@ -1520,8 +1521,10 @@ err:
 static int octeon_mgmt_remove(struct platform_device *pdev)
 {
 	struct net_device *netdev = platform_get_drvdata(pdev);
+	struct octeon_mgmt *p = netdev_priv(netdev);
 
 	unregister_netdev(netdev);
+	of_node_put(p->phy_np);
 	free_netdev(netdev);
 	return 0;
 }
-- 
1.9.1

From: Peter Chen <peter.chen@nxp.com>
Subject: [PATCH v2 12/15] ethernet: renesas: sh_eth: add missing of_node_put after calling of_parse_phandle
Date: Mon, 1 Aug 2016 15:02:40 +0800
Message-ID: <1470034963-30506-13-git-send-email-peter.chen@nxp.com>
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
Received: from mail-bn3nam01on0044.outbound.protection.outlook.com ([104.47.33.44]:28672
	"EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751239AbcHAHMe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2016 03:12:34 -0400
In-Reply-To: <1470034963-30506-1-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_node_put needs to be called when the device node which is got
from of_parse_phandle has finished using.

Signed-off-by: Peter Chen <peter.chen@nxp.com>
Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
---
 drivers/net/ethernet/renesas/sh_eth.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 7bd910c..799d58d 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1780,6 +1780,7 @@ static int sh_eth_phy_init(struct net_device *ndev)
 					sh_eth_adjust_link, 0,
 					mdp->phy_interface);
 
+		of_node_put(pn);
 		if (!phydev)
 			phydev = ERR_PTR(-ENOENT);
 	} else {
-- 
1.9.1

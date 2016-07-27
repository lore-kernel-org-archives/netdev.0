From: Peter Chen <peter.chen@nxp.com>
Subject: [PATCH 09/15] ethernet: marvell: mvpp2: add missing of_node_put after calling of_parse_phandle
Date: Wed, 27 Jul 2016 10:20:42 +0800
Message-ID: <1469586048-15697-10-git-send-email-peter.chen@nxp.com>
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
Received: from mail-by2nam03on0053.outbound.protection.outlook.com ([104.47.42.53]:3200
	"EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758789AbcG0CqF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 22:46:05 -0400
In-Reply-To: <1469586048-15697-1-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_node_put needs to be called when the device node which is got
from of_parse_phandle has finished using.

Signed-off-by: Peter Chen <peter.chen@nxp.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 0b04717..a86f22b 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5531,6 +5531,7 @@ static int mvpp2_phy_connect(struct mvpp2_port *port)
 
 	phy_dev = of_phy_connect(port->dev, port->phy_node, mvpp2_link_event, 0,
 				 port->phy_interface);
+	of_node_put(port->phy_node);
 	if (!phy_dev) {
 		netdev_err(port->dev, "cannot connect to phy\n");
 		return -ENODEV;
@@ -6234,6 +6235,7 @@ err_free_stats:
 err_free_irq:
 	irq_dispose_mapping(port->irq);
 err_free_netdev:
+	of_node_put(phy_node);
 	free_netdev(dev);
 	return err;
 }
-- 
1.9.1

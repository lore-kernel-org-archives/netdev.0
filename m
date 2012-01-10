From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 16/21] davinci_emac: use an unique MDIO bus name.
Date: Tue, 10 Jan 2012 10:59:22 +0100
Message-ID: <1326189567-21663-17-git-send-email-florian@openwrt.org>
References: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Cc: Florian Fainelli <florian@openwrt.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:59903 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932068Ab2AJKBQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 05:01:16 -0500
In-Reply-To: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/ti/davinci_mdio.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 7615040..ef7c9c1 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -313,7 +313,8 @@ static int __devinit davinci_mdio_probe(struct platform_device *pdev)
 	data->bus->reset	= davinci_mdio_reset,
 	data->bus->parent	= dev;
 	data->bus->priv		= data;
-	snprintf(data->bus->id, MII_BUS_ID_SIZE, "%x", pdev->id);
+	snprintf(data->bus->id, MII_BUS_ID_SIZE, "%s-%x",
+		pdev->name, pdev->id);
 
 	data->clk = clk_get(dev, NULL);
 	if (IS_ERR(data->clk)) {
-- 
1.7.5.4

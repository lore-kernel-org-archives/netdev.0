From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 2/4] drivers: net: cpsw-common: add support for reading mac address for dra7 and am437x platforms
Date: Mon, 21 Sep 2015 15:56:51 +0530
Message-ID: <1442831213-3913-3-git-send-email-mugunthanvnm@ti.com>
References: <1442831213-3913-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-omap@vger.kernel.org>,
	"David S . Miller" <davem@davemloft.net>,
	Tony Lindgren <tony@atomide.com>, <devicetree@vger.kernel.org>,
	Sekhar Nori <nsekhar@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:56338 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932165AbbIUK1l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2015 06:27:41 -0400
In-Reply-To: <1442831213-3913-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding support for reading mac address using syscon driver for
dra7 and am437x platforms

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw-common.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw-common.c b/drivers/net/ethernet/ti/cpsw-common.c
index c70417c..c08be62 100644
--- a/drivers/net/ethernet/ti/cpsw-common.c
+++ b/drivers/net/ethernet/ti/cpsw-common.c
@@ -87,6 +87,12 @@ int ti_cm_get_macid(struct device *dev, int slave, u8 *mac_addr)
 	if (of_device_is_compatible(dev->of_node, "ti,dm816-emac"))
 		return cpsw_am33xx_cm_get_macid(dev, 0x30, slave, mac_addr);
 
+	if (of_machine_is_compatible("ti,am4372"))
+		return cpsw_am33xx_cm_get_macid(dev, 0x630, slave, mac_addr);
+
+	if (of_machine_is_compatible("ti,dra7"))
+		return davinci_emac_3517_get_macid(dev, 0x514, slave, mac_addr);
+
 	dev_err(dev, "incompatible machine/device type for reading mac address\n");
 	return -ENOENT;
 }
-- 
2.6.0.rc2.10.gf4d9753

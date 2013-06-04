From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 7/8] drivers: net: ethernet: cpsw: add phy-mode support to cpsw driver
Date: Tue, 4 Jun 2013 11:40:10 +0530
Message-ID: <1370326212-17580-8-git-send-email-mugunthanvnm@ti.com>
References: <1370326212-17580-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <benoit.cousson@linaro.org>,
	<paul@pwsan.com>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:60641 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759260Ab3FDGJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 02:09:56 -0400
In-Reply-To: <1370326212-17580-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding phy-mode support to cpsw driver and updating the cpsw binding
documentation.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt |    6 ++++++
 drivers/net/ethernet/ti/cpsw.c                 |    2 ++
 2 files changed, 8 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index 4f2ca6b..05d660e 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -28,6 +28,8 @@ Optional properties:
 Slave Properties:
 Required properties:
 - phy_id		: Specifies slave phy id
+- phy-mode		: The interface between the SoC and the PHY (a string
+			  that of_get_phy_mode() can understand)
 - mac-address		: Specifies slave MAC address
 
 Optional properties:
@@ -58,11 +60,13 @@ Examples:
 		cpts_clock_shift = <29>;
 		cpsw_emac0: slave@0 {
 			phy_id = <&davinci_mdio>, <0>;
+			phy-mode = "rgmii-txid";
 			/* Filled in by U-Boot */
 			mac-address = [ 00 00 00 00 00 00 ];
 		};
 		cpsw_emac1: slave@1 {
 			phy_id = <&davinci_mdio>, <1>;
+			phy-mode = "rgmii-txid";
 			/* Filled in by U-Boot */
 			mac-address = [ 00 00 00 00 00 00 ];
 		};
@@ -84,11 +88,13 @@ Examples:
 		cpts_clock_shift = <29>;
 		cpsw_emac0: slave@0 {
 			phy_id = <&davinci_mdio>, <0>;
+			phy-mode = "rgmii-txid";
 			/* Filled in by U-Boot */
 			mac-address = [ 00 00 00 00 00 00 ];
 		};
 		cpsw_emac1: slave@1 {
 			phy_id = <&davinci_mdio>, <1>;
+			phy-mode = "rgmii-txid";
 			/* Filled in by U-Boot */
 			mac-address = [ 00 00 00 00 00 00 ];
 		};
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 89a4c40..a45f64e 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1554,6 +1554,8 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		if (mac_addr)
 			memcpy(slave_data->mac_addr, mac_addr, ETH_ALEN);
 
+		slave_data->phy_if = of_get_phy_mode(slave_node);
+
 		if (data->dual_emac) {
 			if (of_property_read_u32(slave_node, "dual_emac_res_vlan",
 						 &prop)) {
-- 
1.7.9.5

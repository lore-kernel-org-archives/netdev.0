From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH 1/2] net: ti cpsw ethernet: allow reading phy interface mode from DT
Date: Wed, 26 Sep 2012 19:24:27 +0200
Message-ID: <1348680268-8194-1-git-send-email-zonque@gmail.com>
Cc: devicetree-discuss@lists.ozlabs.org,
	Daniel Mack <zonque@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Vaibhav Hiremath <hvaibhav@ti.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:44923 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754626Ab2IZRYj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2012 13:24:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow users to specify the phy interface of the CPSW slaves. The new
node parameter is called "phy_if_mode" and is optional. The original
behaviour of the driver is preserved when not given.

Signed-off-by: Daniel Mack <zonque@gmail.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
Cc: Vaibhav Hiremath <hvaibhav@ti.com>
Cc: David S. Miller <davem@davemloft.net>
---
 Documentation/devicetree/bindings/net/cpsw.txt | 3 +++
 drivers/net/ethernet/ti/cpsw.c                 | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index dcaabe9..d87f7d2 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -25,6 +25,8 @@ Required properties:
 - slave_reg_ofs		: Specifies slave register offset
 - sliver_reg_ofs	: Specifies slave sliver register offset
 - phy_id		: Specifies slave phy id
+- phy_if_mode		: Specified slave phy interface mode (optional)
+			  (one of the PHY_INTERFACE_MODE_* as numerical value)
 - mac-address		: Specifies slave MAC address
 
 Optional properties:
@@ -62,6 +64,7 @@ Examples:
 			slave_reg_ofs = <0x208>;
 			sliver_reg_ofs = <0xd80>;
 			phy_id = "davinci_mdio.16:00";
+			phy_if_mode = <6>; /* PHY_INTERFACE_MODE_RGMII */
 			/* Filled in by U-Boot */
 			mac-address = [ 00 00 00 00 00 00 ];
 		};
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index aa78168..3d7594e 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -850,6 +850,9 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		}
 		slave_data->sliver_reg_ofs = prop;
 
+		if (!of_property_read_u32(slave_node, "phy_if_mode", &prop))
+			slave_data->phy_if = prop;
+
 		mac_addr = of_get_mac_address(slave_node);
 		if (mac_addr)
 			memcpy(slave_data->mac_addr, mac_addr, ETH_ALEN);
-- 
1.7.11.4

From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 3/7] cpsw: correct the CPSW_PORT register bank declaration
Date: Mon, 15 Oct 2012 21:48:09 +0200
Message-ID: <88ec565ab25c47b397e8c423169faca5180c2307.1350329726.git.richardcochran@gmail.com>
References: <cover.1350329726.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	Cyril Chemparathy <cyril@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Sriramakrishnan A G <srk@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:48587 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754564Ab2JOTs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 15:48:58 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so4753829wgb.1
        for <netdev@vger.kernel.org>; Mon, 15 Oct 2012 12:48:58 -0700 (PDT)
In-Reply-To: <cover.1350329726.git.richardcochran@gmail.com>
In-Reply-To: <cover.1350329726.git.richardcochran@gmail.com>
References: <cover.1350329726.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit corrects and expands the slave port register bank
according to TI's Technical Reference Manual.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt |    8 ++++----
 arch/arm/boot/dts/am33xx.dtsi                  |    4 ++--
 drivers/net/ethernet/ti/cpsw.c                 |   18 ++++++++++++++----
 3 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index dcaabe9..3af47b7 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -59,14 +59,14 @@ Examples:
 		mac_control = <0x20>;
 		slaves = <2>;
 		cpsw_emac0: slave@0 {
-			slave_reg_ofs = <0x208>;
+			slave_reg_ofs = <0x200>;
 			sliver_reg_ofs = <0xd80>;
 			phy_id = "davinci_mdio.16:00";
 			/* Filled in by U-Boot */
 			mac-address = [ 00 00 00 00 00 00 ];
 		};
 		cpsw_emac1: slave@1 {
-			slave_reg_ofs = <0x308>;
+			slave_reg_ofs = <0x300>;
 			sliver_reg_ofs = <0xdc0>;
 			phy_id = "davinci_mdio.16:01";
 			/* Filled in by U-Boot */
@@ -93,14 +93,14 @@ Examples:
 		mac_control = <0x20>;
 		slaves = <2>;
 		cpsw_emac0: slave@0 {
-			slave_reg_ofs = <0x208>;
+			slave_reg_ofs = <0x200>;
 			sliver_reg_ofs = <0xd80>;
 			phy_id = "davinci_mdio.16:00";
 			/* Filled in by U-Boot */
 			mac-address = [ 00 00 00 00 00 00 ];
 		};
 		cpsw_emac1: slave@1 {
-			slave_reg_ofs = <0x308>;
+			slave_reg_ofs = <0x300>;
 			sliver_reg_ofs = <0xdc0>;
 			phy_id = "davinci_mdio.16:01";
 			/* Filled in by U-Boot */
diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
index f6bea04..cd9b3b4 100644
--- a/arch/arm/boot/dts/am33xx.dtsi
+++ b/arch/arm/boot/dts/am33xx.dtsi
@@ -238,13 +238,13 @@
 			interrupts = <40 41 42 43>;
 			ranges;
 			cpsw_emac0: slave@0 {
-				slave_reg_ofs = <0x208>;
+				slave_reg_ofs = <0x200>;
 				sliver_reg_ofs = <0xd80>;
 				/* Filled in by U-Boot */
 				mac-address = [ 00 00 00 00 00 00 ];
 			};
 			cpsw_emac1: slave@1 {
-				slave_reg_ofs = <0x308>;
+				slave_reg_ofs = <0x300>;
 				sliver_reg_ofs = <0xdc0>;
 				/* Filled in by U-Boot */
 				mac-address = [ 00 00 00 00 00 00 ];
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 1bdbb36..e29bb8f 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -157,16 +157,26 @@ struct cpsw_ss_regs {
 };
 
 struct cpsw_slave_regs {
+	u32	control;
+	u32	res1;
 	u32	max_blks;
 	u32	blk_cnt;
-	u32	flow_thresh;
+	u32	tx_in_ctl;
 	u32	port_vlan;
 	u32	tx_pri_map;
-	u32	ts_ctl;
-	u32	ts_seq_ltype;
-	u32	ts_vlan;
+	u32	ts_seq_mtype;
 	u32	sa_lo;
 	u32	sa_hi;
+	u32	send_percent;
+	u32	res2;
+	u32	rx_dscp_pri_map0;
+	u32	rx_dscp_pri_map1;
+	u32	rx_dscp_pri_map2;
+	u32	rx_dscp_pri_map3;
+	u32	rx_dscp_pri_map4;
+	u32	rx_dscp_pri_map5;
+	u32	rx_dscp_pri_map6;
+	u32	rx_dscp_pri_map7;
 };
 
 struct cpsw_host_regs {
-- 
1.7.2.5

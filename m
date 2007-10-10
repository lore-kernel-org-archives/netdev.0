From: Timur Tabi <timur@freescale.com>
Subject: [PATCH 2/2] ucc_geth: use rx-clock-name and tx-clock-name device tree properties
Date: Wed, 10 Oct 2007 17:18:28 -0500
Message-ID: <11920547102323-git-send-email-timur@freescale.com>
References: <1192054708946-git-send-email-timur@freescale.com>
 <11920547093580-git-send-email-timur@freescale.com>
Cc: Timur Tabi <timur@freescale.com>
To: galak@kernel.crashing.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:41297 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754116AbXJJWSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 18:18:41 -0400
In-Reply-To: <11920547093580-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch updates the ucc_geth device driver to check the new rx-clock-name
and tx-clock-name properties first.  If present, it uses the new function
qe_clock_source() to obtain the clock source.  Otherwise, it checks the
deprecated rx-clock and tx-clock properties.

The device trees for 832x, 836x, and 8568 have been updated to contain the
new property names only.

Signed-off-by: Timur Tabi <timur@freescale.com>
---

This patch applies to Kumar's for-2.6.24 branch, on top of my other patch titled
"qe: add function qe_clock_source".

 arch/powerpc/boot/dts/mpc832x_mds.dts |    8 ++++----
 arch/powerpc/boot/dts/mpc832x_rdb.dts |    8 ++++----
 arch/powerpc/boot/dts/mpc836x_mds.dts |    8 ++++----
 arch/powerpc/boot/dts/mpc8568mds.dts  |    8 ++++----
 drivers/net/ucc_geth.c                |   12 +++++-------
 5 files changed, 21 insertions(+), 23 deletions(-)

diff --git a/arch/powerpc/boot/dts/mpc832x_mds.dts b/arch/powerpc/boot/dts/mpc832x_mds.dts
index fcd333c..b57485b 100644
--- a/arch/powerpc/boot/dts/mpc832x_mds.dts
+++ b/arch/powerpc/boot/dts/mpc832x_mds.dts
@@ -217,8 +217,8 @@
 			 */
 			mac-address = [ 00 00 00 00 00 00 ];
 			local-mac-address = [ 00 00 00 00 00 00 ];
-			rx-clock = <19>;
-			tx-clock = <1a>;
+			rx-clock-name = "clk9";
+			tx-clock-name = "clk10";
 			phy-handle = < &phy3 >;
 			pio-handle = < &pio3 >;
 		};
@@ -238,8 +238,8 @@
 			 */
 			mac-address = [ 00 00 00 00 00 00 ];
 			local-mac-address = [ 00 00 00 00 00 00 ];
-			rx-clock = <17>;
-			tx-clock = <18>;
+			rx-clock-name = "clk7";
+			tx-clock-name = "clk8";
 			phy-handle = < &phy4 >;
 			pio-handle = < &pio4 >;
 		};
diff --git a/arch/powerpc/boot/dts/mpc832x_rdb.dts b/arch/powerpc/boot/dts/mpc832x_rdb.dts
index 388c8a7..e68a08b 100644
--- a/arch/powerpc/boot/dts/mpc832x_rdb.dts
+++ b/arch/powerpc/boot/dts/mpc832x_rdb.dts
@@ -202,8 +202,8 @@
 			 */
 			mac-address = [ 00 00 00 00 00 00 ];
 			local-mac-address = [ 00 00 00 00 00 00 ];
-			rx-clock = <20>;
-			tx-clock = <13>;
+			rx-clock-name = "clk16";
+			tx-clock-name = "clk3";
 			phy-handle = <&phy00>;
 			pio-handle = <&ucc2pio>;
 		};
@@ -223,8 +223,8 @@
 			 */
 			mac-address = [ 00 00 00 00 00 00 ];
 			local-mac-address = [ 00 00 00 00 00 00 ];
-			rx-clock = <19>;
-			tx-clock = <1a>;
+			rx-clock-name = "clk9";
+			tx-clock-name = "clk10";
 			phy-handle = <&phy04>;
 			pio-handle = <&ucc3pio>;
 		};
diff --git a/arch/powerpc/boot/dts/mpc836x_mds.dts b/arch/powerpc/boot/dts/mpc836x_mds.dts
index fbd1573..7a54072 100644
--- a/arch/powerpc/boot/dts/mpc836x_mds.dts
+++ b/arch/powerpc/boot/dts/mpc836x_mds.dts
@@ -245,8 +245,8 @@
 			 */
 			mac-address = [ 00 00 00 00 00 00 ];
 			local-mac-address = [ 00 00 00 00 00 00 ];
-			rx-clock = <0>;
-			tx-clock = <19>;
+			rx-clock-name = "none";
+			tx-clock-name = "clk9";
 			phy-handle = < &phy0 >;
 			phy-connection-type = "rgmii-id";
 			pio-handle = < &pio1 >;
@@ -267,8 +267,8 @@
 			 */
 			mac-address = [ 00 00 00 00 00 00 ];
 			local-mac-address = [ 00 00 00 00 00 00 ];
-			rx-clock = <0>;
-			tx-clock = <14>;
+			rx-clock-name = "none";
+			tx-clock-name = "clk4";
 			phy-handle = < &phy1 >;
 			phy-connection-type = "rgmii-id";
 			pio-handle = < &pio2 >;
diff --git a/arch/powerpc/boot/dts/mpc8568mds.dts b/arch/powerpc/boot/dts/mpc8568mds.dts
index 5439437..cf45aab 100644
--- a/arch/powerpc/boot/dts/mpc8568mds.dts
+++ b/arch/powerpc/boot/dts/mpc8568mds.dts
@@ -333,8 +333,8 @@
 			 */
 			mac-address = [ 00 00 00 00 00 00 ];
 			local-mac-address = [ 00 00 00 00 00 00 ];
-			rx-clock = <0>;
-			tx-clock = <20>;
+			rx-clock-name = "none";
+			tx-clock-name = "clk16";
 			pio-handle = <&pio1>;
 			phy-handle = <&phy0>;
 			phy-connection-type = "rgmii-id";
@@ -355,8 +355,8 @@
 			 */
 			mac-address = [ 00 00 00 00 00 00 ];
 			local-mac-address = [ 00 00 00 00 00 00 ];
-			rx-clock = <0>;
-			tx-clock = <20>;
+			rx-clock-name = "none";
+			tx-clock-name = "clk16";
 			pio-handle = <&pio2>;
 			phy-handle = <&phy1>;
 			phy-connection-type = "rgmii-id";
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index a147d6e..9308397 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3863,7 +3863,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	sprop = of_get_property(np, "rx-clock-name", NULL);
 	if (sprop) {
 		ug_info->uf_info.rx_clock = qe_clock_source(sprop);
-		if ((ug_info->uf_info.rx_clock < QE_CLK1) ||
+		if ((ug_info->uf_info.rx_clock < QE_CLK_NONE) ||
 		    (ug_info->uf_info.rx_clock > QE_CLK24)) {
 			printk(KERN_ERR
 				"ucc_geth: invalid rx-clock-name property\n");
@@ -3873,12 +3873,12 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		prop = of_get_property(np, "rx-clock", NULL);
 		if (!prop) {
 			/* If both rx-clock-name and rx-clock are missing,
-                           we want to tell people to use rx-clock-name. */
+			   we want to tell people to use rx-clock-name. */
 			printk(KERN_ERR
 				"ucc_geth: missing rx-clock-name property\n");
 			return -EINVAL;
 		}
-		if ((*prop < QE_CLK1) || (*prop > QE_CLK24)) {
+		if ((*prop < QE_CLK_NONE) || (*prop > QE_CLK24)) {
 			printk(KERN_ERR
 				"ucc_geth: invalid rx-clock propperty\n");
 			return -EINVAL;
@@ -3889,7 +3889,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	sprop = of_get_property(np, "tx-clock-name", NULL);
 	if (sprop) {
 		ug_info->uf_info.tx_clock = qe_clock_source(sprop);
-		if ((ug_info->uf_info.tx_clock < QE_CLK1) ||
+		if ((ug_info->uf_info.tx_clock < QE_CLK_NONE) ||
 		    (ug_info->uf_info.tx_clock > QE_CLK24)) {
 			printk(KERN_ERR
 				"ucc_geth: invalid tx-clock-name property\n");
@@ -3902,7 +3902,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 				"ucc_geth: mising tx-clock-name property\n");
 			return -EINVAL;
 		}
-		if ((*prop < QE_CLK1) || (*prop > QE_CLK24)) {
+		if ((*prop < QE_CLK_NONE) || (*prop > QE_CLK24)) {
 			printk(KERN_ERR
 				"ucc_geth: invalid tx-clock property\n");
 			return -EINVAL;
@@ -3910,8 +3910,6 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		ug_info->uf_info.tx_clock = *prop;
 	}
 
-	prop = of_get_property(np, "tx-clock", NULL);
-	ug_info->uf_info.tx_clock = *prop;
 	err = of_address_to_resource(np, 0, &res);
 	if (err)
 		return -EINVAL;
-- 
1.5.2.4


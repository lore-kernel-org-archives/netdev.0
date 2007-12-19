From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 2/4] [POWERPC][NET] ucc_geth_mii and users: get rid of device_type
Date: Wed, 19 Dec 2007 23:37:57 +0300
Message-ID: <20071219203757.GB20861@localhost.localdomain>
References: <20071219203447.GA18285@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: linuxppc-dev@ozlabs.org, Jeff Garzik <jgarzik@pobox.com>,
	Li Yang <leoli@freescale.com>, netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:6601 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751418AbXLSUfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 15:35:46 -0500
Content-Disposition: inline
In-Reply-To: <20071219203447.GA18285@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

device_type property is bogus, better use proper compatible property.

Also change compatible to "fsl,ucc-mdio".

Per http://ozlabs.org/pipermail/linuxppc-dev/2007-December/048388.html

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 arch/powerpc/boot/dts/mpc832x_mds.dts |    3 +--
 arch/powerpc/boot/dts/mpc832x_rdb.dts |    3 +--
 arch/powerpc/boot/dts/mpc836x_mds.dts |    3 +--
 arch/powerpc/boot/dts/mpc8568mds.dts  |    2 +-
 drivers/net/ucc_geth_mii.c            |    3 +--
 5 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/arch/powerpc/boot/dts/mpc832x_mds.dts b/arch/powerpc/boot/dts/mpc832x_mds.dts
index ef8cd1e..97757ed 100644
--- a/arch/powerpc/boot/dts/mpc832x_mds.dts
+++ b/arch/powerpc/boot/dts/mpc832x_mds.dts
@@ -254,8 +254,7 @@
 			#address-cells = <1>;
 			#size-cells = <0>;
 			reg = <2320 18>;
-			device_type = "mdio";
-			compatible = "ucc_geth_phy";
+			compatible = "fsl,ucc-mdio";
 
 			phy3: ethernet-phy@03 {
 				interrupt-parent = < &ipic >;
diff --git a/arch/powerpc/boot/dts/mpc832x_rdb.dts b/arch/powerpc/boot/dts/mpc832x_rdb.dts
index 7c4f028..b1c73f1 100644
--- a/arch/powerpc/boot/dts/mpc832x_rdb.dts
+++ b/arch/powerpc/boot/dts/mpc832x_rdb.dts
@@ -235,8 +235,7 @@
 			#address-cells = <1>;
 			#size-cells = <0>;
 			reg = <3120 18>;
-			device_type = "mdio";
-			compatible = "ucc_geth_phy";
+			compatible = "fsl,ucc-mdio";
 
 			phy00:ethernet-phy@00 {
 				interrupt-parent = <&pic>;
diff --git a/arch/powerpc/boot/dts/mpc836x_mds.dts b/arch/powerpc/boot/dts/mpc836x_mds.dts
index 5c73786..330212d 100644
--- a/arch/powerpc/boot/dts/mpc836x_mds.dts
+++ b/arch/powerpc/boot/dts/mpc836x_mds.dts
@@ -287,8 +287,7 @@
 			#address-cells = <1>;
 			#size-cells = <0>;
 			reg = <2120 18>;
-			device_type = "mdio";
-			compatible = "ucc_geth_phy";
+			compatible = "fsl,ucc-mdio";
 
 			phy0: ethernet-phy@00 {
 				interrupt-parent = < &ipic >;
diff --git a/arch/powerpc/boot/dts/mpc8568mds.dts b/arch/powerpc/boot/dts/mpc8568mds.dts
index 7ad4b9f..c00aec9 100644
--- a/arch/powerpc/boot/dts/mpc8568mds.dts
+++ b/arch/powerpc/boot/dts/mpc8568mds.dts
@@ -355,7 +355,7 @@
 			#address-cells = <1>;
 			#size-cells = <0>;
 			reg = <2120 18>;
-			compatible = "ucc_geth_phy";
+			compatible = "fsl,ucc-mdio";
 
 			/* These are the same PHYs as on
 			 * gianfar's MDIO bus */
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index df884f0..de8ba1f 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -253,8 +253,7 @@ int uec_mdio_remove(struct of_device *ofdev)
 
 static struct of_device_id uec_mdio_match[] = {
 	{
-		.type = "mdio",
-		.compatible = "ucc_geth_phy",
+		.compatible = "fsl,ucc-mdio",
 	},
 	{},
 };
-- 
1.5.2.2


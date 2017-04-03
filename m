From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v3 17/20] ARM: dts: sun50i-a64: enable dwmac-sun8i on pine64 plus
Date: Mon,  3 Apr 2017 11:14:41 +0200
Message-ID: <20170403091444.29876-18-clabbe.montjoie@gmail.com>
References: <20170403091444.29876-1-clabbe.montjoie@gmail.com>
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35935 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751435AbdDCJRb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 05:17:31 -0400
In-Reply-To: <20170403091444.29876-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dwmac-sun8i hardware is present on the pine64 plus.
It uses an external PHY rtl8211e via RGMII.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 .../arm64/boot/dts/allwinner/sun50i-a64-pine64-plus.dts | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/boot/dts/allwinner/sun50i-a64-pine64-plus.dts b/arch/arm64/boot/dts/allwinner/sun50i-a64-pine64-plus.dts
index 790d14d..dea76c2 100644
--- a/arch/arm64/boot/dts/allwinner/sun50i-a64-pine64-plus.dts
+++ b/arch/arm64/boot/dts/allwinner/sun50i-a64-pine64-plus.dts
@@ -46,5 +46,20 @@
 	model = "Pine64+";
 	compatible = "pine64,pine64-plus", "allwinner,sun50i-a64";
 
-	/* TODO: Camera, Ethernet PHY, touchscreen, etc. */
+	/* TODO: Camera, touchscreen, etc. */
+};
+
+&mdio {
+	ext_rgmii_phy: ethernet-phy@1 {
+		compatible = "ethernet-phy-ieee802.3-c22";
+		reg = <1>;
+	};
+};
+
+&emac {
+	pinctrl-names = "default";
+	pinctrl-0 = <&rgmii_pins>;
+	phy-mode = "rgmii";
+	phy-handle = <&ext_rgmii_phy>;
+	status = "okay";
 };
-- 
2.10.2

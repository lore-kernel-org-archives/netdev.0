From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 39/40] ARM: dts: imx6qdl-nitrogen6x: add phy interrupt to eliminate polling
Date: Thu, 28 Jan 2016 14:26:03 -0700
Message-ID: <1454016364-30985-40-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34829 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967866AbcA1V3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:29:15 -0500
Received: by mail-pa0-f53.google.com with SMTP id ho8so29149908pac.2
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:29:14 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 arch/arm/boot/dts/imx6qdl-nitrogen6x.dtsi | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/arch/arm/boot/dts/imx6qdl-nitrogen6x.dtsi b/arch/arm/boot/dts/imx6qdl-nitrogen6x.dtsi
index caeed56..1d42331 100644
--- a/arch/arm/boot/dts/imx6qdl-nitrogen6x.dtsi
+++ b/arch/arm/boot/dts/imx6qdl-nitrogen6x.dtsi
@@ -288,6 +288,15 @@
 	interrupts-extended = <&gpio1 6 IRQ_TYPE_LEVEL_HIGH>,
 			      <&intc 0 119 IRQ_TYPE_LEVEL_HIGH>;
 	status = "okay";
+	phy-handle = <&ethphy>;
+	mdio {
+		#address-cells = <0>;
+		#size-cells = <1>;
+		ethphy: ethernet-phy@6 {
+			reg = <6>;
+			interrupts-extended = <&gpio1 28 IRQ_TYPE_LEVEL_LOW>;
+		};
+	};
 };
 
 &hdmi {
@@ -409,6 +418,8 @@
 				/* Phy reset */
 				MX6QDL_PAD_ENET_RXD0__GPIO1_IO27	0x000b0
 				MX6QDL_PAD_GPIO_6__ENET_IRQ		0x000b1
+				/* ethernet phy interrupt */
+				MX6QDL_PAD_ENET_TX_EN__GPIO1_IO28	0x1b0b0
 			>;
 		};
 
-- 
2.5.0

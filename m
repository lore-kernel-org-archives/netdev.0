From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH 4/4] arm64: dts: renesas: ulcb: Add EthernetAVB PHY reset
Date: Thu, 28 Sep 2017 17:53:34 +0200
Message-ID: <1506614014-4398-5-git-send-email-geert+renesas@glider.be>
References: <1506614014-4398-1-git-send-email-geert+renesas@glider.be>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, devicetree@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S . Miller" <davem@davemloft.net>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from baptiste.telenet-ops.be ([195.130.132.51]:46050 "EHLO
        baptiste.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752022AbdI1PyA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 11:54:00 -0400
In-Reply-To: <1506614014-4398-1-git-send-email-geert+renesas@glider.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Describe the GPIO used to reset the Ethernet PHY for EthernetAVB.
This allows the driver to reset the PHY during probe and after system
resume.

On ULCB, the enable pin of the regulator providing PHY power is always
pulled high, but the driver may still need to reset the PHY if this
wasn't done by the bootloader before.

Inspired by patches in the BSP for the individual Salvator-X/XS boards
by Kazuya Mizuguchi.

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
Compile-tested only.
---
 arch/arm64/boot/dts/renesas/ulcb.dtsi | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm64/boot/dts/renesas/ulcb.dtsi b/arch/arm64/boot/dts/renesas/ulcb.dtsi
index dfec9072718b8da1..49cf392fccfb3165 100644
--- a/arch/arm64/boot/dts/renesas/ulcb.dtsi
+++ b/arch/arm64/boot/dts/renesas/ulcb.dtsi
@@ -147,6 +147,7 @@
 	pinctrl-names = "default";
 	renesas,no-ether-link;
 	phy-handle = <&phy0>;
+	reset-gpios = <&gpio2 10 GPIO_ACTIVE_LOW>;
 	status = "okay";
 
 	phy0: ethernet-phy@0 {
-- 
2.7.4

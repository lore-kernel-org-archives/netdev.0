From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH v4 7/7] arm64: dts: NS2: add AMAC ethernet support
Date: Tue,  1 Nov 2016 16:04:42 -0400
Message-ID: <1478030682-27012-8-git-send-email-jon.mason@broadcom.com>
References: <1478030682-27012-1-git-send-email-jon.mason@broadcom.com>
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35516 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932612AbcKAUFJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 16:05:09 -0400
Received: by mail-pf0-f179.google.com with SMTP id i88so6822823pfk.2
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 13:05:09 -0700 (PDT)
In-Reply-To: <1478030682-27012-1-git-send-email-jon.mason@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the AMAC ethernet to the Broadcom Northstar2 SoC device
tree

Signed-off-by: Jon Mason <jon.mason@broadcom.com>
---
 arch/arm64/boot/dts/broadcom/ns2-svk.dts |  5 +++++
 arch/arm64/boot/dts/broadcom/ns2.dtsi    | 12 ++++++++++++
 2 files changed, 17 insertions(+)

diff --git a/arch/arm64/boot/dts/broadcom/ns2-svk.dts b/arch/arm64/boot/dts/broadcom/ns2-svk.dts
index 2d7872a..2e4d90d 100644
--- a/arch/arm64/boot/dts/broadcom/ns2-svk.dts
+++ b/arch/arm64/boot/dts/broadcom/ns2-svk.dts
@@ -56,6 +56,10 @@
 	};
 };
 
+&enet {
+	status = "ok";
+};
+
 &pci_phy0 {
 	status = "ok";
 };
@@ -172,6 +176,7 @@
 &mdio_mux_iproc {
 	mdio@10 {
 		gphy0: eth-phy@10 {
+			enet-phy-lane-swap;
 			reg = <0x10>;
 		};
 	};
diff --git a/arch/arm64/boot/dts/broadcom/ns2.dtsi b/arch/arm64/boot/dts/broadcom/ns2.dtsi
index d95dc40..773ed59 100644
--- a/arch/arm64/boot/dts/broadcom/ns2.dtsi
+++ b/arch/arm64/boot/dts/broadcom/ns2.dtsi
@@ -191,6 +191,18 @@
 
 		#include "ns2-clock.dtsi"
 
+		enet: ethernet@61000000 {
+			compatible = "brcm,ns2-amac";
+			reg = <0x61000000 0x1000>,
+			      <0x61090000 0x1000>,
+			      <0x61030000 0x100>;
+			reg-names = "amac_base", "idm_base", "nicpm_base";
+			interrupts = <GIC_SPI 341 IRQ_TYPE_LEVEL_HIGH>;
+			phy-handle = <&gphy0>;
+			phy-mode = "rgmii";
+			status = "disabled";
+		};
+
 		dma0: dma@61360000 {
 			compatible = "arm,pl330", "arm,primecell";
 			reg = <0x61360000 0x1000>;
-- 
2.7.4

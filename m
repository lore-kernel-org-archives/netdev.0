From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH] ARM: at91/dt: sama5d3 xplained: add phy address for macb1
Date: Tue, 31 Mar 2015 10:56:10 +0200
Message-ID: <1427792170-13162-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Johan Hovold <johan@kernel.org>, <stable@vger.kernel.org>
To: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After 57a38effa598 (net: phy: micrel: disable broadcast for KSZ8081/KSZ8091)
the macb1 interface refuses to work properly because it tries
to cling to address 0 which isn't able to communicate in broadcast with
the mac anymore. The micrel phy on the board is actually configured
to show up at address 1.
Adding the phy node and its real address fixes the issue.

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
Cc: Johan Hovold <johan@kernel.org>
Cc: <stable@vger.kernel.org> #3.19
---
 arch/arm/boot/dts/at91-sama5d3_xplained.dts | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/arm/boot/dts/at91-sama5d3_xplained.dts b/arch/arm/boot/dts/at91-sama5d3_xplained.dts
index fec1fca2ad66..6c4bc53cbf4e 100644
--- a/arch/arm/boot/dts/at91-sama5d3_xplained.dts
+++ b/arch/arm/boot/dts/at91-sama5d3_xplained.dts
@@ -167,7 +167,13 @@
 
 			macb1: ethernet@f802c000 {
 				phy-mode = "rmii";
+				#address-cells = <1>;
+				#size-cells = <0>;
 				status = "okay";
+
+				ethernet-phy@1 {
+					reg = <0x1>;
+				};
 			};
 
 			dbgu: serial@ffffee00 {
-- 
2.1.3

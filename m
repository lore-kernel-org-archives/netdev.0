From: Vitaly Bordug <vitb@kernel.crashing.org>
Subject: [PATCH 3/3] [POWERPC] MPC8349E-mITX: Vitesse 7385 PHY is not
	connected to the MDIO bus
Date: Mon, 26 Nov 2007 17:29:22 +0300
Message-ID: <20071126142922.19642.47964.stgit@localhost.localdomain>
References: <20071126142906.19642.45540.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:48617 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754635AbXKZO3d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2007 09:29:33 -0500
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linuxppc-dev@ozlabs.org
In-Reply-To: <20071126142906.19642.45540.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


...thus use fixed-link to register proper "Fixed PHY"

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
Signed-off-by: Vitaly Bordug <vitb@kernel.crashing.org>

---

 arch/powerpc/boot/dts/mpc8349emitx.dts |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)


diff --git a/arch/powerpc/boot/dts/mpc8349emitx.dts b/arch/powerpc/boot/dts/mpc8349emitx.dts
index 5072f6d..e2d00f1 100644
--- a/arch/powerpc/boot/dts/mpc8349emitx.dts
+++ b/arch/powerpc/boot/dts/mpc8349emitx.dts
@@ -115,14 +115,6 @@
 				reg = <1c>;
 				device_type = "ethernet-phy";
 			};
-
-			/* Vitesse 7385 */
-			phy1f: ethernet-phy@1f {
-				interrupt-parent = < &ipic >;
-				interrupts = <12 8>;
-				reg = <1f>;
-				device_type = "ethernet-phy";
-			};
 		};
 
 		ethernet@24000 {
@@ -159,7 +151,8 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <23 8 24 8 25 8>;
 			interrupt-parent = < &ipic >;
-			phy-handle = < &phy1f >;
+			/* Vitesse 7385 isn't on the MDIO bus */
+			fixed-link = <1 1 d#1000>;
 			linux,network-index = <1>;
 		};
 


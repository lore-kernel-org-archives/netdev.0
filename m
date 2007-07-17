From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH 2/4] gianfar: Add phy-connection-type to gianfar nodes
Date: Mon, 16 Jul 2007 20:26:59 -0500
Message-ID: <11846356233423-git-send-email-afleming@freescale.com>
References: <1184635621688-git-send-email-afleming@freescale.com> <1184635622653-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Andy Fleming <afleming@freescale.com>
To: jgarzik@pobox.com, paulus@samba.org, galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:35662 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755929AbXGQB1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 21:27:36 -0400
In-Reply-To: <1184635622653-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The TSEC/eTSEC automatically detect their PHY interface type, unless
the type is RGMII-ID (RGMII with internal delay).  In that situation,
it just detects RGMII.  In order to fix this, we need to pass in rgmii-id
if that is the connection type.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 Documentation/powerpc/booting-without-of.txt |    6 ++++++
 arch/powerpc/boot/dts/mpc8641_hpcn.dts       |    4 ++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/Documentation/powerpc/booting-without-of.txt b/Documentation/powerpc/booting-without-of.txt
index d42d981..a41b6b1 100644
--- a/Documentation/powerpc/booting-without-of.txt
+++ b/Documentation/powerpc/booting-without-of.txt
@@ -1241,6 +1241,12 @@ platforms are moved over to use the flattened-device-tree model.
       network device.  This is used by the bootwrapper to interpret
       MAC addresses passed by the firmware when no information other
       than indices is available to associate an address with a device.
+    - phy-connection-type : a string naming the controller/PHY interface type,
+      i.e., "mii" (default), "rmii", "gmii", "rgmii", "rgmii-id", "sgmii",
+      "tbi", or "rtbi".  This property is only really needed if the connection
+      is of type "rgmii-id", as all other connection types are detected by
+      hardware.
+
 
   Example:
 
diff --git a/arch/powerpc/boot/dts/mpc8641_hpcn.dts b/arch/powerpc/boot/dts/mpc8641_hpcn.dts
index 260b264..9849073 100644
--- a/arch/powerpc/boot/dts/mpc8641_hpcn.dts
+++ b/arch/powerpc/boot/dts/mpc8641_hpcn.dts
@@ -121,6 +121,7 @@
 			interrupts = <1d 2 1e 2 22 2>;
 			interrupt-parent = <&mpic>;
 			phy-handle = <&phy0>;
+			phy-connection-type = "rgmii-id";
 		};
 
 		ethernet@25000 {
@@ -134,6 +135,7 @@
 			interrupts = <23 2 24 2 28 2>;
 			interrupt-parent = <&mpic>;
 			phy-handle = <&phy1>;
+			phy-connection-type = "rgmii-id";
 		};
 		
 		ethernet@26000 {
@@ -147,6 +149,7 @@
 			interrupts = <1F 2 20 2 21 2>;
 			interrupt-parent = <&mpic>;
 			phy-handle = <&phy2>;
+			phy-connection-type = "rgmii-id";
 		};
 
 		ethernet@27000 {
@@ -160,6 +163,7 @@
 			interrupts = <25 2 26 2 27 2>;
 			interrupt-parent = <&mpic>;
 			phy-handle = <&phy3>;
+			phy-connection-type = "rgmii-id";
 		};
 		serial@4500 {
 			device_type = "serial";
-- 
1.5.0.2.230.gfbe3d-dirty


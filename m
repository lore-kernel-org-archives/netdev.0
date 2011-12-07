From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH] powerpc: Add TBI PHY node to first MDIO bus
Date: Wed, 7 Dec 2011 13:50:57 -0600
Message-ID: <1323287457-6085-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>
To: Kumar Gala <galak@kernel.crashing.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe005.messaging.microsoft.com ([213.199.154.143]:28424
	"EHLO DB3EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756604Ab1LGTvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 14:51:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Systems which use the fsl_pq_mdio driver need to specify an
address for TBI PHY transactions such that the address does
not conflict with any PHYs on the bus (all transactions to
that address are directed to the onboard TBI PHY). The driver
used to scan for a free address if no address was specified,
however this ran into issues when the PHY Lib was fixed so
that all MDIO transactions were protected by a mutex. As it
is, the code was meant to serve as a transitional tool until
the device trees were all updated to specify the TBI address.

The best fix for the mutex issue was to remove the scanning code,
but it turns out some of the newer SoCs have started to omit
the tbi-phy node when SGMII is not being used. As such, these
devices will now fail unless we add a tbi-phy node to the first
mdio controller.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---

This requires fsl_pq_mdio: Clean up tbi address configuration from
the net tree in order to achieve its full effect.

This needs to go into 3.2.

 arch/powerpc/boot/dts/p1010rdb.dts            |    5 +++++
 arch/powerpc/boot/dts/p1020rdb.dts            |    5 +++++
 arch/powerpc/boot/dts/p1020rdb_camp_core0.dts |    5 +++++
 arch/powerpc/boot/dts/p1021mds.dts            |    4 ++++
 arch/powerpc/boot/dts/p1022ds.dts             |    4 ++++
 arch/powerpc/boot/dts/p2020rdb.dts            |    8 ++++++--
 arch/powerpc/boot/dts/p2020rdb_camp_core0.dts |    4 ++++
 7 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/boot/dts/p1010rdb.dts b/arch/powerpc/boot/dts/p1010rdb.dts
index d6c669c..e1f9683 100644
--- a/arch/powerpc/boot/dts/p1010rdb.dts
+++ b/arch/powerpc/boot/dts/p1010rdb.dts
@@ -193,6 +193,11 @@
 				interrupts = <2 1>;
 				reg = <0x2>;
 			};
+
+			tbi-phy@3 {
+				device-type = "tbi-phy";
+				reg = <0x3>;
+			};
 		};
 
 		enet0: ethernet@b0000 {
diff --git a/arch/powerpc/boot/dts/p1020rdb.dts b/arch/powerpc/boot/dts/p1020rdb.dts
index d6a8ae4..72e4fc4 100644
--- a/arch/powerpc/boot/dts/p1020rdb.dts
+++ b/arch/powerpc/boot/dts/p1020rdb.dts
@@ -209,6 +209,11 @@
 				interrupts = <2 1>;
 				reg = <0x1>;
 			};
+
+			tbi-phy@2 {
+				device_type = "tbi-phy";
+				reg = <0x2>;
+			};
 		};
 
 		mdio@25000 {
diff --git a/arch/powerpc/boot/dts/p1020rdb_camp_core0.dts b/arch/powerpc/boot/dts/p1020rdb_camp_core0.dts
index f0bf7f4..ad805a1 100644
--- a/arch/powerpc/boot/dts/p1020rdb_camp_core0.dts
+++ b/arch/powerpc/boot/dts/p1020rdb_camp_core0.dts
@@ -112,6 +112,11 @@
 				interrupts = <2 1>;
 				reg = <0x1>;
 			};
+
+			tbi-phy@2 {
+				device-type = "tbi-phy";
+				reg = <0x2>;
+			};
 		};
 
 		mdio@25000 {
diff --git a/arch/powerpc/boot/dts/p1021mds.dts b/arch/powerpc/boot/dts/p1021mds.dts
index ad5b852..ba53b4b 100644
--- a/arch/powerpc/boot/dts/p1021mds.dts
+++ b/arch/powerpc/boot/dts/p1021mds.dts
@@ -338,6 +338,10 @@
 				interrupt-parent = <&mpic>;
 				reg = <0x4>;
 			};
+			tbi-phy@5 {
+				device_type = "tbi-phy";
+				reg = <0x5>;
+			};
 		};
 
 		mdio@25000 {
diff --git a/arch/powerpc/boot/dts/p1022ds.dts b/arch/powerpc/boot/dts/p1022ds.dts
index 89ca93e..4bf382d 100644
--- a/arch/powerpc/boot/dts/p1022ds.dts
+++ b/arch/powerpc/boot/dts/p1022ds.dts
@@ -391,6 +391,10 @@
 				interrupts = <9 1 0 0>;
 				reg = <0x2>;
 			};
+			tbi-phy@2 {
+				device_type = "tbi-phy";
+				reg = <0x2>;
+			};
 		};
 
 		mdio@25000 {
diff --git a/arch/powerpc/boot/dts/p2020rdb.dts b/arch/powerpc/boot/dts/p2020rdb.dts
index 1d7a05f..9e4ae85 100644
--- a/arch/powerpc/boot/dts/p2020rdb.dts
+++ b/arch/powerpc/boot/dts/p2020rdb.dts
@@ -205,12 +205,16 @@
 				interrupt-parent = <&mpic>;
 				interrupts = <3 1>;
 				reg = <0x0>;
-				};
+			};
 			phy1: ethernet-phy@1 {
 				interrupt-parent = <&mpic>;
 				interrupts = <3 1>;
 				reg = <0x1>;
-				};
+			};
+			tbi-phy@2 {
+				device_type = "tbi-phy";
+				reg = <0x2>;
+			};
 		};
 
 		mdio@25520 {
diff --git a/arch/powerpc/boot/dts/p2020rdb_camp_core0.dts b/arch/powerpc/boot/dts/p2020rdb_camp_core0.dts
index fc8dddd..8e5bda1 100644
--- a/arch/powerpc/boot/dts/p2020rdb_camp_core0.dts
+++ b/arch/powerpc/boot/dts/p2020rdb_camp_core0.dts
@@ -122,6 +122,10 @@
 				interrupts = <3 1>;
 				reg = <0x1>;
 			};
+			tbi-phy@2 {
+				device_type = "tbi-phy";
+				reg = <0x2>;
+			};
 		};
 
 		mdio@25520 {
-- 
1.7.3.4

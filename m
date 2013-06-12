From: Oded Gabbay <ogabbay@advaoptical.com>
Subject: [PATCH] MDIO: FSL_PQ_MDIO: Fix bug on incorrect offset of tbipa register
Date: Wed, 12 Jun 2013 15:47:38 +0300
Message-ID: <1371041258-15298-1-git-send-email-ogabbay@advaoptical.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: <benh@kernel.crashing.org>, <paulus@samba.org>,
	<leoli@freescale.com>, <galak@kernel.crashing.org>,
	<B38951@freescale.com>, <Dongsheng.Wang@freescale.com>,
	<bigeasy@linutronix.de>, <stef.van.os@prodrive.nl>,
	<timur@tabi.org>, <davem@davemloft.net>, <ogabbay@advaoptical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a bug in the fsl_pq_mdio.c module and in relevant device-tree
files regarding the correct offset of the tbipa register in the eTSEC
controller in some of Freescale's PQ3 and QorIQ SoC.
The bug happens when the mdio in the device tree is configured to be compatible
to "fsl,gianfar-tbi". Because the mdio device in the device tree points to
addresses 25520, 26520 or 27520 (depends on the controller ID), the variable
priv->map at function fsl_pq_mdio_probe, points to that address. However,
later in the function there is a write to register tbipa that is actually
located at 25030, 26030 or 27030. Because the correct address is not io mapped,
the contents are written to a different register in the controller.
The fix sets the address of the mdio device to start at 25000, 26000 or 27000
and changes the mii_offset field to 0x520 in the relevant entry
(fsl,gianfar-tbi) of the fsl_pq_mdio_match array.

Note: This patch may break MDIO functionallity of some old Freescale's SoC
until Freescale will fix their device tree files. Basically, every device tree
which contains an mdio device that is compatible to "fsl,gianfar-tbi" should be
examined.

Signed-off-by: Oded Gabbay <ogabbay@advaoptical.com>
---
 arch/powerpc/boot/dts/fsl/pq3-etsec1-1.dtsi    | 4 ++--
 arch/powerpc/boot/dts/fsl/pq3-etsec1-2.dtsi    | 4 ++--
 arch/powerpc/boot/dts/fsl/pq3-etsec1-3.dtsi    | 4 ++--
 arch/powerpc/boot/dts/ge_imp3a.dts             | 4 ++--
 arch/powerpc/boot/dts/mpc8536ds.dtsi           | 4 ++--
 arch/powerpc/boot/dts/mpc8544ds.dtsi           | 2 +-
 arch/powerpc/boot/dts/mpc8548cds.dtsi          | 6 +++---
 arch/powerpc/boot/dts/mpc8568mds.dts           | 2 +-
 arch/powerpc/boot/dts/mpc8572ds.dtsi           | 6 +++---
 arch/powerpc/boot/dts/mpc8572ds_camp_core0.dts | 4 ++--
 arch/powerpc/boot/dts/mpc8572ds_camp_core1.dts | 2 +-
 arch/powerpc/boot/dts/p2020ds.dtsi             | 4 ++--
 arch/powerpc/boot/dts/p2020rdb-pc.dtsi         | 4 ++--
 arch/powerpc/boot/dts/p2020rdb.dts             | 4 ++--
 arch/powerpc/boot/dts/ppa8548.dts              | 6 +++---
 drivers/net/ethernet/freescale/fsl_pq_mdio.c   | 2 +-
 16 files changed, 31 insertions(+), 31 deletions(-)

diff --git a/arch/powerpc/boot/dts/fsl/pq3-etsec1-1.dtsi b/arch/powerpc/boot/dts/fsl/pq3-etsec1-1.dtsi
index 96693b4..d38bf63 100644
--- a/arch/powerpc/boot/dts/fsl/pq3-etsec1-1.dtsi
+++ b/arch/powerpc/boot/dts/fsl/pq3-etsec1-1.dtsi
@@ -46,9 +46,9 @@ ethernet@25000 {
 	interrupts = <35 2 0 0 36 2 0 0 40 2 0 0>;
 };
 
-mdio@25520 {
+mdio@25000 {
 	#address-cells = <1>;
 	#size-cells = <0>;
 	compatible = "fsl,gianfar-tbi";
-	reg = <0x25520 0x20>;
+	reg = <0x25000 0x1000>;
 };
diff --git a/arch/powerpc/boot/dts/fsl/pq3-etsec1-2.dtsi b/arch/powerpc/boot/dts/fsl/pq3-etsec1-2.dtsi
index 6b3fab1..6290b49 100644
--- a/arch/powerpc/boot/dts/fsl/pq3-etsec1-2.dtsi
+++ b/arch/powerpc/boot/dts/fsl/pq3-etsec1-2.dtsi
@@ -46,9 +46,9 @@ ethernet@26000 {
 	interrupts = <31 2 0 0 32 2 0 0 33 2 0 0>;
 };
 
-mdio@26520 {
+mdio@26000 {
 	#address-cells = <1>;
 	#size-cells = <0>;
 	compatible = "fsl,gianfar-tbi";
-	reg = <0x26520 0x20>;
+	reg = <0x26000 0x1000>;
 };
diff --git a/arch/powerpc/boot/dts/fsl/pq3-etsec1-3.dtsi b/arch/powerpc/boot/dts/fsl/pq3-etsec1-3.dtsi
index 0da592d..5296811 100644
--- a/arch/powerpc/boot/dts/fsl/pq3-etsec1-3.dtsi
+++ b/arch/powerpc/boot/dts/fsl/pq3-etsec1-3.dtsi
@@ -46,9 +46,9 @@ ethernet@27000 {
 	interrupts = <37 2 0 0 38 2 0 0 39 2 0 0>;
 };
 
-mdio@27520 {
+mdio@27000 {
 	#address-cells = <1>;
 	#size-cells = <0>;
 	compatible = "fsl,gianfar-tbi";
-	reg = <0x27520 0x20>;
+	reg = <0x27000 0x1000>;
 };
diff --git a/arch/powerpc/boot/dts/ge_imp3a.dts b/arch/powerpc/boot/dts/ge_imp3a.dts
index fefae41..49d9b4e 100644
--- a/arch/powerpc/boot/dts/ge_imp3a.dts
+++ b/arch/powerpc/boot/dts/ge_imp3a.dts
@@ -174,14 +174,14 @@
 			};
 		};
 
-		mdio@25520 {
+		mdio@25000 {
 			tbi1: tbi-phy@11 {
 				reg = <0x11>;
 				device_type = "tbi-phy";
 			};
 		};
 
-		mdio@26520 {
+		mdio@26000 {
 			status = "disabled";
 		};
 
diff --git a/arch/powerpc/boot/dts/mpc8536ds.dtsi b/arch/powerpc/boot/dts/mpc8536ds.dtsi
index 7c3dde8..c4df5a1 100644
--- a/arch/powerpc/boot/dts/mpc8536ds.dtsi
+++ b/arch/powerpc/boot/dts/mpc8536ds.dtsi
@@ -227,11 +227,11 @@
 		phy-connection-type = "rgmii-id";
 	};
 
-	mdio@26520 {
+	mdio@26000 {
 		#address-cells = <1>;
 		#size-cells = <0>;
 		compatible = "fsl,gianfar-tbi";
-		reg = <0x26520 0x20>;
+		reg = <0x26000 0x1000>;
 
 		tbi1: tbi-phy@11 {
 			reg = <0x11>;
diff --git a/arch/powerpc/boot/dts/mpc8544ds.dtsi b/arch/powerpc/boot/dts/mpc8544ds.dtsi
index b219d03..ba051b2 100644
--- a/arch/powerpc/boot/dts/mpc8544ds.dtsi
+++ b/arch/powerpc/boot/dts/mpc8544ds.dtsi
@@ -111,7 +111,7 @@
 		phy-connection-type = "rgmii-id";
 	};
 
-	mdio@26520 {
+	mdio@26000 {
 		tbi1: tbi-phy@11 {
 			reg = <0x11>;
 			device_type = "tbi-phy";
diff --git a/arch/powerpc/boot/dts/mpc8548cds.dtsi b/arch/powerpc/boot/dts/mpc8548cds.dtsi
index c61f525..85da565 100644
--- a/arch/powerpc/boot/dts/mpc8548cds.dtsi
+++ b/arch/powerpc/boot/dts/mpc8548cds.dtsi
@@ -137,7 +137,7 @@
 		phy-handle = <&phy1>;
 	};
 
-	mdio@25520 {
+	mdio@25000 {
 		tbi1: tbi-phy@11 {
 			reg = <0x11>;
 			device_type = "tbi-phy";
@@ -149,7 +149,7 @@
 		phy-handle = <&phy2>;
 	};
 
-	mdio@26520 {
+	mdio@26000 {
 		tbi2: tbi-phy@11 {
 			reg = <0x11>;
 			device_type = "tbi-phy";
@@ -161,7 +161,7 @@
 		phy-handle = <&phy3>;
 	};
 
-	mdio@27520 {
+	mdio@27000 {
 		tbi3: tbi-phy@11 {
 			reg = <0x11>;
 			device_type = "tbi-phy";
diff --git a/arch/powerpc/boot/dts/mpc8568mds.dts b/arch/powerpc/boot/dts/mpc8568mds.dts
index 09598bb..30cd8b8 100644
--- a/arch/powerpc/boot/dts/mpc8568mds.dts
+++ b/arch/powerpc/boot/dts/mpc8568mds.dts
@@ -120,7 +120,7 @@
 			sleep = <&pmc 0x00000040>;
 		};
 
-		mdio@25520 {
+		mdio@25000 {
 			tbi1: tbi-phy@11 {
 				reg = <0x11>;
 				device_type = "tbi-phy";
diff --git a/arch/powerpc/boot/dts/mpc8572ds.dtsi b/arch/powerpc/boot/dts/mpc8572ds.dtsi
index 357490b..c82a800 100644
--- a/arch/powerpc/boot/dts/mpc8572ds.dtsi
+++ b/arch/powerpc/boot/dts/mpc8572ds.dtsi
@@ -208,7 +208,7 @@
 
 	};
 
-	mdio@25520 {
+	mdio@25000 {
 		tbi1: tbi-phy@11 {
 			reg = <0x11>;
 			device_type = "tbi-phy";
@@ -221,7 +221,7 @@
 		phy-connection-type = "rgmii-id";
 
 	};
-	mdio@26520 {
+	mdio@26000 {
 		tbi2: tbi-phy@11 {
 			reg = <0x11>;
 			device_type = "tbi-phy";
@@ -234,7 +234,7 @@
 		phy-connection-type = "rgmii-id";
 	};
 
-	mdio@27520 {
+	mdio@27000 {
 		tbi3: tbi-phy@11 {
 			reg = <0x11>;
 			device_type = "tbi-phy";
diff --git a/arch/powerpc/boot/dts/mpc8572ds_camp_core0.dts b/arch/powerpc/boot/dts/mpc8572ds_camp_core0.dts
index ef9ef56..5dae410 100644
--- a/arch/powerpc/boot/dts/mpc8572ds_camp_core0.dts
+++ b/arch/powerpc/boot/dts/mpc8572ds_camp_core0.dts
@@ -47,13 +47,13 @@
 		ethernet@26000 {
 			status = "disabled";
 		};
-		mdio@26520 {
+		mdio@26000 {
 			status = "disabled";
 		};
 		ethernet@27000 {
 			status = "disabled";
 		};
-		mdio@27520 {
+		mdio@27000 {
 			status = "disabled";
 		};
 		pic@40000 {
diff --git a/arch/powerpc/boot/dts/mpc8572ds_camp_core1.dts b/arch/powerpc/boot/dts/mpc8572ds_camp_core1.dts
index 24564ee..706e782 100644
--- a/arch/powerpc/boot/dts/mpc8572ds_camp_core1.dts
+++ b/arch/powerpc/boot/dts/mpc8572ds_camp_core1.dts
@@ -73,7 +73,7 @@
 		ethernet@25000 {
 			status = "disabled";
 		};
-		mdio@25520 {
+		mdio@25000 {
 			status = "disabled";
 		};
 		crypto@30000 {
diff --git a/arch/powerpc/boot/dts/p2020ds.dtsi b/arch/powerpc/boot/dts/p2020ds.dtsi
index e699cf9..1e9001c 100644
--- a/arch/powerpc/boot/dts/p2020ds.dtsi
+++ b/arch/powerpc/boot/dts/p2020ds.dtsi
@@ -167,14 +167,14 @@
 
 	};
 
-	mdio@25520 {
+	mdio@25000 {
 		tbi1: tbi-phy@11 {
 			reg = <0x11>;
 			device_type = "tbi-phy";
 		};
 	};
 
-	mdio@26520 {
+	mdio@26000 {
 		tbi2: tbi-phy@11 {
 			reg = <0x11>;
 			device_type = "tbi-phy";
diff --git a/arch/powerpc/boot/dts/p2020rdb-pc.dtsi b/arch/powerpc/boot/dts/p2020rdb-pc.dtsi
index c21d1c7..994cb4c 100644
--- a/arch/powerpc/boot/dts/p2020rdb-pc.dtsi
+++ b/arch/powerpc/boot/dts/p2020rdb-pc.dtsi
@@ -203,14 +203,14 @@
 			};
 	};
 
-	mdio@25520 {
+	mdio@25000 {
 		tbi0: tbi-phy@11 {
 			reg = <0x11>;
 			device_type = "tbi-phy";
 		};
 	};
 
-	mdio@26520 {
+	mdio@26000 {
 		status = "disabled";
 	};
 
diff --git a/arch/powerpc/boot/dts/p2020rdb.dts b/arch/powerpc/boot/dts/p2020rdb.dts
index 4d52bce..b6f50e1 100644
--- a/arch/powerpc/boot/dts/p2020rdb.dts
+++ b/arch/powerpc/boot/dts/p2020rdb.dts
@@ -215,14 +215,14 @@
 			};
 		};
 
-		mdio@25520 {
+		mdio@25000 {
 			tbi0: tbi-phy@11 {
 				reg = <0x11>;
 				device_type = "tbi-phy";
 			};
 		};
 
-		mdio@26520 {
+		mdio@26000 {
 			status = "disabled";
 		};
 
diff --git a/arch/powerpc/boot/dts/ppa8548.dts b/arch/powerpc/boot/dts/ppa8548.dts
index f97ecee..2117927 100644
--- a/arch/powerpc/boot/dts/ppa8548.dts
+++ b/arch/powerpc/boot/dts/ppa8548.dts
@@ -128,7 +128,7 @@
 		phy-handle = <&phy0>;
 	};
 
-	mdio@25520 {
+	mdio@25000 {
 		tbi1: tbi-phy@11 {
 			reg = <0x11>;
 			device_type = "tbi-phy";
@@ -140,7 +140,7 @@
 		phy-handle = <&phy1>;
 	};
 
-	mdio@26520 {
+	mdio@26000 {
 		tbi2: tbi-phy@11 {
 			reg = <0x11>;
 			device_type = "tbi-phy";
@@ -151,7 +151,7 @@
 		status = "disabled";
 	};
 
-	mdio@27520 {
+	mdio@27000 {
 		tbi3: tbi-phy@11 {
 			reg = <0x11>;
 			device_type = "tbi-phy";
diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index c93a056..4228c4e 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -288,7 +288,7 @@ static struct of_device_id fsl_pq_mdio_match[] = {
 	{
 		.compatible = "fsl,gianfar-tbi",
 		.data = &(struct fsl_pq_mdio_data) {
-			.mii_offset = 0,
+			.mii_offset = 0x520,
 			.get_tbipa = get_gfar_tbipa,
 		},
 	},
-- 
1.8.3.1

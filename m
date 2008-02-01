From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] [POWERPC][NET][SERIAL] UCCs: replace device-id with cell-index (was: Re: [PATCH] [POWERPC] get rid of `model = "UCC"' in the ucc nodes)
Date: Fri, 1 Feb 2008 20:33:31 +0300
Message-ID: <20080201173331.GA8020@localhost.localdomain>
References: <20080201150126.GB26545@localhost.localdomain> <72B60725-FB4A-42FA-832D-8FD5434B9042@kernel.crashing.org>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Jeff Garzik <jgarzik@pobox.com>, Timur Tabi <timur@freescale.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Li Yang <leoli@freescale.com>, linuxppc-dev@ozlabs.org,
	linux-serial@vger.kernel.org, netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <linux-serial-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <72B60725-FB4A-42FA-832D-8FD5434B9042@kernel.crashing.org>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 01, 2008 at 09:32:38AM -0600, Kumar Gala wrote:
> On Feb 1, 2008, at 9:01 AM, Anton Vorontsov wrote:
> 
> >It isn't used anywhere, so remove it. If we'll ever need something
> >like this, we'll use compatible property instead.
> >
> >Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> >---
> >
> >Rebased on top of recent tree.
> >
> >Documentation/powerpc/booting-without-of.txt |    1 -
> >arch/powerpc/boot/dts/mpc832x_mds.dts        |    3 ---
> >arch/powerpc/boot/dts/mpc832x_rdb.dts        |    2 --
> >arch/powerpc/boot/dts/mpc836x_mds.dts        |    2 --
> >arch/powerpc/boot/dts/mpc8568mds.dts         |    2 --
> >5 files changed, 0 insertions(+), 10 deletions(-)
> >
> >diff --git a/Documentation/powerpc/booting-without-of.txt b/ 
> >Documentation/powerpc/booting-without-of.txt
> >index 410c847..dcf9758 100644
> >--- a/Documentation/powerpc/booting-without-of.txt
> >+++ b/Documentation/powerpc/booting-without-of.txt
> >@@ -1675,7 +1675,6 @@ platforms are moved over to use the flattened- 
> >device-tree model.
> >	ucc@2000 {
> >		device_type = "network";
> >		compatible = "ucc_geth";
> >-		model = "UCC";
> >		device-id = <1>;
> 
> can we change device-id to cell-index?

Sure. But let's do this in the separate patch? Because this change
actually touches the code in the two subsystems: net and serial.

I hope everybody will agree to pass it through powerpc tree..?

- - - -
From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [POWERPC][NET][SERIAL] UCCs: replace device-id with cell-index

device-id is worse than cell-index. Probably cell-index isn't
good either, but device-id is worse anyway.

Drivers are modified for backward compatibility's sake.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 Documentation/powerpc/booting-without-of.txt |    4 ++--
 arch/powerpc/boot/dts/mpc832x_mds.dts        |    4 +---
 arch/powerpc/boot/dts/mpc832x_rdb.dts        |    2 --
 arch/powerpc/boot/dts/mpc836x_mds.dts        |    2 --
 arch/powerpc/boot/dts/mpc836x_rdk.dts        |   12 ++++++------
 arch/powerpc/boot/dts/mpc8568mds.dts         |    2 --
 drivers/net/ucc_geth.c                       |    8 +++++++-
 drivers/net/ucc_geth_mii.c                   |   11 ++++++++---
 drivers/serial/ucc_uart.c                    |   16 ++++++++++++----
 9 files changed, 36 insertions(+), 25 deletions(-)

diff --git a/Documentation/powerpc/booting-without-of.txt b/Documentation/powerpc/booting-without-of.txt
index dcf9758..7b30798 100644
--- a/Documentation/powerpc/booting-without-of.txt
+++ b/Documentation/powerpc/booting-without-of.txt
@@ -1618,7 +1618,7 @@ platforms are moved over to use the flattened-device-tree model.
      "bisync", "atm", or "serial".
    - compatible : could be "ucc_geth" or "fsl_atm" and so on.
    - model : should be "UCC".
-   - device-id : the ucc number(1-8), corresponding to UCCx in UM.
+   - cell-index : the ucc number(1-8), corresponding to UCCx in UM.
    - reg : Offset and length of the register set for the device
    - interrupts : <a b> where a is the interrupt number and b is a
      field that represents an encoding of the sense and level
@@ -1675,7 +1675,7 @@ platforms are moved over to use the flattened-device-tree model.
 	ucc@2000 {
 		device_type = "network";
 		compatible = "ucc_geth";
-		device-id = <1>;
+		cell-index = <1>;
 		reg = <2000 200>;
 		interrupts = <a0 0>;
 		interrupt-parent = <700>;
diff --git a/arch/powerpc/boot/dts/mpc832x_mds.dts b/arch/powerpc/boot/dts/mpc832x_mds.dts
index f8b4a37..539e02f 100644
--- a/arch/powerpc/boot/dts/mpc832x_mds.dts
+++ b/arch/powerpc/boot/dts/mpc832x_mds.dts
@@ -256,7 +256,6 @@
 			device_type = "network";
 			compatible = "ucc_geth";
 			cell-index = <3>;
-			device-id = <3>;
 			reg = <0x2200 0x200>;
 			interrupts = <34>;
 			interrupt-parent = <&qeic>;
@@ -271,7 +270,6 @@
 			device_type = "network";
 			compatible = "ucc_geth";
 			cell-index = <4>;
-			device-id = <4>;
 			reg = <0x3200 0x200>;
 			interrupts = <35>;
 			interrupt-parent = <&qeic>;
@@ -285,7 +283,7 @@
 		ucc@2400 {
 			device_type = "serial";
 			compatible = "ucc_uart";
-			device-id = <5>;	/* The UCC number, 1-7*/
+			cell-index = <5>;	/* The UCC number, 1-7*/
 			port-number = <0>;	/* Which ttyQEx device */
 			soft-uart;		/* We need Soft-UART */
 			reg = <0x2400 0x200>;
diff --git a/arch/powerpc/boot/dts/mpc832x_rdb.dts b/arch/powerpc/boot/dts/mpc832x_rdb.dts
index ea7fcbf..179c81c 100644
--- a/arch/powerpc/boot/dts/mpc832x_rdb.dts
+++ b/arch/powerpc/boot/dts/mpc832x_rdb.dts
@@ -209,7 +209,6 @@
 			device_type = "network";
 			compatible = "ucc_geth";
 			cell-index = <2>;
-			device-id = <2>;
 			reg = <0x3000 0x200>;
 			interrupts = <33>;
 			interrupt-parent = <&qeic>;
@@ -224,7 +223,6 @@
 			device_type = "network";
 			compatible = "ucc_geth";
 			cell-index = <3>;
-			device-id = <3>;
 			reg = <0x2200 0x200>;
 			interrupts = <34>;
 			interrupt-parent = <&qeic>;
diff --git a/arch/powerpc/boot/dts/mpc836x_mds.dts b/arch/powerpc/boot/dts/mpc836x_mds.dts
index 525423c..8160ff2 100644
--- a/arch/powerpc/boot/dts/mpc836x_mds.dts
+++ b/arch/powerpc/boot/dts/mpc836x_mds.dts
@@ -258,7 +258,6 @@
 			device_type = "network";
 			compatible = "ucc_geth";
 			cell-index = <1>;
-			device-id = <1>;
 			reg = <0x2000 0x200>;
 			interrupts = <32>;
 			interrupt-parent = <&qeic>;
@@ -274,7 +273,6 @@
 			device_type = "network";
 			compatible = "ucc_geth";
 			cell-index = <2>;
-			device-id = <2>;
 			reg = <0x3000 0x200>;
 			interrupts = <33>;
 			interrupt-parent = <&qeic>;
diff --git a/arch/powerpc/boot/dts/mpc836x_rdk.dts b/arch/powerpc/boot/dts/mpc836x_rdk.dts
index e35200a..cc56338 100644
--- a/arch/powerpc/boot/dts/mpc836x_rdk.dts
+++ b/arch/powerpc/boot/dts/mpc836x_rdk.dts
@@ -179,7 +179,7 @@
 			enet0: ucc@2000 {
 				device_type = "network";
 				compatible = "ucc_geth";
-				device-id = <1>;
+				cell-index = <1>;
 				reg = <0x2000 0x200>;
 				interrupts = <32>;
 				interrupt-parent = <&qeic>;
@@ -194,7 +194,7 @@
 			enet1: ucc@3000 {
 				device_type = "network";
 				compatible = "ucc_geth";
-				device-id = <2>;
+				cell-index = <2>;
 				reg = <0x3000 0x200>;
 				interrupts = <33>;
 				interrupt-parent = <&qeic>;
@@ -209,7 +209,7 @@
 			enet2: ucc@2600 {
 				device_type = "network";
 				compatible = "ucc_geth";
-				device-id = <7>;
+				cell-index = <7>;
 				reg = <0x2600 0x200>;
 				interrupts = <42>;
 				interrupt-parent = <&qeic>;
@@ -224,7 +224,7 @@
 			enet3: ucc@3200 {
 				device_type = "network";
 				compatible = "ucc_geth";
-				device-id = <4>;
+				cell-index = <4>;
 				reg = <0x3200 0x200>;
 				interrupts = <35>;
 				interrupt-parent = <&qeic>;
@@ -271,7 +271,7 @@
 				device_type = "serial";
 				compatible = "ucc_uart";
 				reg = <0x2400 0x200>;
-				device-id = <5>;
+				cell-index = <5>;
 				port-number = <0>;
 				rx-clock-name = "brg7";
 				tx-clock-name = "brg8";
@@ -284,7 +284,7 @@
 				device_type = "serial";
 				compatible = "ucc_uart";
 				reg = <0x3400 0x200>;
-				device-id = <6>;
+				cell-index = <6>;
 				port-number = <1>;
 				rx-clock-name = "brg13";
 				tx-clock-name = "brg14";
diff --git a/arch/powerpc/boot/dts/mpc8568mds.dts b/arch/powerpc/boot/dts/mpc8568mds.dts
index 66087d5..df4b5e8 100644
--- a/arch/powerpc/boot/dts/mpc8568mds.dts
+++ b/arch/powerpc/boot/dts/mpc8568mds.dts
@@ -325,7 +325,6 @@
 			device_type = "network";
 			compatible = "ucc_geth";
 			cell-index = <1>;
-			device-id = <1>;
 			reg = <2000 200>;
 			interrupts = <20>;
 			interrupt-parent = <&qeic>;
@@ -341,7 +340,6 @@
 			device_type = "network";
 			compatible = "ucc_geth";
 			cell-index = <2>;
-			device-id = <2>;
 			reg = <3000 200>;
 			interrupts = <21>;
 			interrupt-parent = <&qeic>;
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index fba0811..3a68b94 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3852,7 +3852,13 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 
 	ugeth_vdbg("%s: IN", __FUNCTION__);
 
-	prop = of_get_property(np, "device-id", NULL);
+	prop = of_get_property(np, "cell-index", NULL);
+	if (!prop) {
+		prop = of_get_property(np, "device-id", NULL);
+		if (!prop)
+			return -ENODEV;
+	}
+
 	ucc_num = *prop - 1;
 	if ((ucc_num < 0) || (ucc_num > 7))
 		return -ENODEV;
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index e3ba14a..e5b17d7 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -203,9 +203,14 @@ static int uec_mdio_probe(struct of_device *ofdev, const struct of_device_id *ma
 		if ((res.start >= tempres.start) &&
 		    (res.end <= tempres.end)) {
 			/* set this UCC to be the MII master */
-			const u32 *id = of_get_property(tempnp, "device-id", NULL);
-			if (id == NULL)
-				goto bus_register_fail;
+			const u32 *id;
+
+			id = of_get_property(tempnp, "cell-index", NULL);
+			if (!id) {
+				id = of_get_property(tempnp, "device-id", NULL);
+				if (!id)
+					goto bus_register_fail;
+			}
 
 			ucc_set_qe_mux_mii_mng(*id - 1);
 
diff --git a/drivers/serial/ucc_uart.c b/drivers/serial/ucc_uart.c
index e0994f0..5e4310c 100644
--- a/drivers/serial/ucc_uart.c
+++ b/drivers/serial/ucc_uart.c
@@ -1270,10 +1270,18 @@ static int ucc_uart_probe(struct of_device *ofdev,
 
 	/* Get the UCC number (device ID) */
 	/* UCCs are numbered 1-7 */
-	iprop = of_get_property(np, "device-id", NULL);
-	if (!iprop || (*iprop < 1) || (*iprop > UCC_MAX_NUM)) {
-		dev_err(&ofdev->dev,
-			"missing or invalid UCC specified in device tree\n");
+	iprop = of_get_property(np, "cell-index", NULL);
+	if (!iprop) {
+		iprop = of_get_property(np, "device-id", NULL);
+		if (!iprop) {
+			dev_err(&ofdev->dev, "UCC is unspecified in "
+				"device tree\n");
+			return -EINVAL;
+		}
+	}
+
+	if ((*iprop < 1) || (*iprop > UCC_MAX_NUM)) {
+		dev_err(&ofdev->dev, "no support for UCC%u\n", *iprop);
 		kfree(qe_port);
 		return -ENODEV;
 	}
-- 
1.5.2.2


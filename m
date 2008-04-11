From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH 2/2] [POWERPC] UCC nodes cleanup
Date: Fri, 11 Apr 2008 20:06:54 +0400
Message-ID: <20080411160654.GA25506@polina.dev.rtsoft.ru>
References: <20080311171045.GB4684@localhost.localdomain> <82E8E38A-C159-4C23-BDE8-086D4429F366@kernel.crashing.org>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: linuxppc-dev@ozlabs.org, Jeff Garzik <jgarzik@pobox.com>,
	netdev@vger.kernel.org, linux-serial@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:6882 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760122AbYDKQG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 12:06:57 -0400
Content-Disposition: inline
In-Reply-To: <82E8E38A-C159-4C23-BDE8-086D4429F366@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 11, 2008 at 09:13:36AM -0500, Kumar Gala wrote:
>
> On Mar 11, 2008, at 12:10 PM, Anton Vorontsov wrote:
>> - get rid of `model = "UCC"' in the ucc nodes
>>  It isn't used anywhere, so remove it. If we'll ever need something
>>  like this, we'll use compatible property instead.
>> - replace cell-index and device-id properties by fsl,ucc.
>>
>> Drivers are modified for backward compatibility's sake.
>
> I'd prefer we use cell-index and not introduce "fsl,ucc".  I'm ok with  
> dropping device-id and model (its implied in the compatiable).

Ok. Here it is. netdev and linux-serial Cc'ed.

- - - -
From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [POWERPC] UCC nodes cleanup

- get rid of `model = "UCC"' in the ucc nodes
  It isn't used anywhere, so remove it. If we'll ever need something
  like this, we'll use compatible property instead.
- replace last occurrences of device-id with cell-index.
  Drivers are modified for backward compatibility's sake.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 Documentation/powerpc/booting-without-of.txt |    6 ++----
 arch/powerpc/boot/dts/mpc832x_mds.dts        |    7 +------
 arch/powerpc/boot/dts/mpc832x_rdb.dts        |    4 ----
 arch/powerpc/boot/dts/mpc836x_mds.dts        |    4 ----
 arch/powerpc/boot/dts/mpc8568mds.dts         |    4 ----
 drivers/net/ucc_geth.c                       |    8 +++++++-
 drivers/net/ucc_geth_mii.c                   |   11 ++++++++---
 drivers/serial/ucc_uart.c                    |   16 ++++++++++++----
 8 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/Documentation/powerpc/booting-without-of.txt b/Documentation/powerpc/booting-without-of.txt
index be41a5c..f0a99aa 100644
--- a/Documentation/powerpc/booting-without-of.txt
+++ b/Documentation/powerpc/booting-without-of.txt
@@ -1619,8 +1619,7 @@ platforms are moved over to use the flattened-device-tree model.
    - device_type : should be "network", "hldc", "uart", "transparent"
      "bisync", "atm", or "serial".
    - compatible : could be "ucc_geth" or "fsl_atm" and so on.
-   - model : should be "UCC".
-   - device-id : the ucc number(1-8), corresponding to UCCx in UM.
+   - cell-index : the ucc number(1-8), corresponding to UCCx in UM.
    - reg : Offset and length of the register set for the device
    - interrupts : <a b> where a is the interrupt number and b is a
      field that represents an encoding of the sense and level
@@ -1677,8 +1676,7 @@ platforms are moved over to use the flattened-device-tree model.
 	ucc@2000 {
 		device_type = "network";
 		compatible = "ucc_geth";
-		model = "UCC";
-		device-id = <1>;
+		cell-index = <1>;
 		reg = <2000 200>;
 		interrupts = <a0 0>;
 		interrupt-parent = <700>;
diff --git a/arch/powerpc/boot/dts/mpc832x_mds.dts b/arch/powerpc/boot/dts/mpc832x_mds.dts
index 9bb4083..539e02f 100644
--- a/arch/powerpc/boot/dts/mpc832x_mds.dts
+++ b/arch/powerpc/boot/dts/mpc832x_mds.dts
@@ -255,9 +255,7 @@
 		enet0: ucc@2200 {
 			device_type = "network";
 			compatible = "ucc_geth";
-			model = "UCC";
 			cell-index = <3>;
-			device-id = <3>;
 			reg = <0x2200 0x200>;
 			interrupts = <34>;
 			interrupt-parent = <&qeic>;
@@ -271,9 +269,7 @@
 		enet1: ucc@3200 {
 			device_type = "network";
 			compatible = "ucc_geth";
-			model = "UCC";
 			cell-index = <4>;
-			device-id = <4>;
 			reg = <0x3200 0x200>;
 			interrupts = <35>;
 			interrupt-parent = <&qeic>;
@@ -287,8 +283,7 @@
 		ucc@2400 {
 			device_type = "serial";
 			compatible = "ucc_uart";
-			model = "UCC";
-			device-id = <5>;	/* The UCC number, 1-7*/
+			cell-index = <5>;	/* The UCC number, 1-7*/
 			port-number = <0>;	/* Which ttyQEx device */
 			soft-uart;		/* We need Soft-UART */
 			reg = <0x2400 0x200>;
diff --git a/arch/powerpc/boot/dts/mpc832x_rdb.dts b/arch/powerpc/boot/dts/mpc832x_rdb.dts
index 94f93d2..179c81c 100644
--- a/arch/powerpc/boot/dts/mpc832x_rdb.dts
+++ b/arch/powerpc/boot/dts/mpc832x_rdb.dts
@@ -208,9 +208,7 @@
 		enet0: ucc@3000 {
 			device_type = "network";
 			compatible = "ucc_geth";
-			model = "UCC";
 			cell-index = <2>;
-			device-id = <2>;
 			reg = <0x3000 0x200>;
 			interrupts = <33>;
 			interrupt-parent = <&qeic>;
@@ -224,9 +222,7 @@
 		enet1: ucc@2200 {
 			device_type = "network";
 			compatible = "ucc_geth";
-			model = "UCC";
 			cell-index = <3>;
-			device-id = <3>;
 			reg = <0x2200 0x200>;
 			interrupts = <34>;
 			interrupt-parent = <&qeic>;
diff --git a/arch/powerpc/boot/dts/mpc836x_mds.dts b/arch/powerpc/boot/dts/mpc836x_mds.dts
index 55f03e8..8160ff2 100644
--- a/arch/powerpc/boot/dts/mpc836x_mds.dts
+++ b/arch/powerpc/boot/dts/mpc836x_mds.dts
@@ -257,9 +257,7 @@
 		enet0: ucc@2000 {
 			device_type = "network";
 			compatible = "ucc_geth";
-			model = "UCC";
 			cell-index = <1>;
-			device-id = <1>;
 			reg = <0x2000 0x200>;
 			interrupts = <32>;
 			interrupt-parent = <&qeic>;
@@ -274,9 +272,7 @@
 		enet1: ucc@3000 {
 			device_type = "network";
 			compatible = "ucc_geth";
-			model = "UCC";
 			cell-index = <2>;
-			device-id = <2>;
 			reg = <0x3000 0x200>;
 			interrupts = <33>;
 			interrupt-parent = <&qeic>;
diff --git a/arch/powerpc/boot/dts/mpc8568mds.dts b/arch/powerpc/boot/dts/mpc8568mds.dts
index 97bc048..df4b5e8 100644
--- a/arch/powerpc/boot/dts/mpc8568mds.dts
+++ b/arch/powerpc/boot/dts/mpc8568mds.dts
@@ -324,9 +324,7 @@
 		enet2: ucc@2000 {
 			device_type = "network";
 			compatible = "ucc_geth";
-			model = "UCC";
 			cell-index = <1>;
-			device-id = <1>;
 			reg = <2000 200>;
 			interrupts = <20>;
 			interrupt-parent = <&qeic>;
@@ -341,9 +339,7 @@
 		enet3: ucc@3000 {
 			device_type = "network";
 			compatible = "ucc_geth";
-			model = "UCC";
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
index c69e654..8a48ddb 100644
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
1.5.4.5


From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH v2 12/13] powerpc/440: Hacks to ml507 .dts and Marvell PHY
	driver to test ll_temac
Date: Sat, 21 Mar 2009 16:29:18 -0600
Message-ID: <20090321222918.20493.49830.stgit@localhost.localdomain>
References: <20090321222047.20493.87335.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, galak@kernel.crashing.org,
	davem@davemloft.net
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, olof@lixom.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:30079 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756111AbZCUW3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 18:29:25 -0400
Received: by wf-out-1314.google.com with SMTP id 29so2085855wff.4
        for <netdev@vger.kernel.org>; Sat, 21 Mar 2009 15:29:24 -0700 (PDT)
In-Reply-To: <20090321222047.20493.87335.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

CC: Yoshio Kashiwagi <kashiwagi@co-nss.co.jp>
CC: David H. Lynch Jr. <dhlii@dlasys.net>
CC: John Linn <john.linn@xilinx.com>
CC: John Bonesio <john.bonesio@xilinx.com>
CC: David DeBonis <ddeboni@xilinx.com>
CC: Wilson Yang <wyang@xilinx.com>

For information and testing only.  Do not merge to mainline
---

 arch/powerpc/boot/dts/virtex440-ml507.dts |   14 ++++++++++----
 drivers/net/phy/marvell.c                 |    2 ++
 2 files changed, 12 insertions(+), 4 deletions(-)


diff --git a/arch/powerpc/boot/dts/virtex440-ml507.dts b/arch/powerpc/boot/dts/virtex440-ml507.dts
index 52d8c1a..65cc433 100644
--- a/arch/powerpc/boot/dts/virtex440-ml507.dts
+++ b/arch/powerpc/boot/dts/virtex440-ml507.dts
@@ -31,7 +31,7 @@
 		reg = < 0 0x10000000 >;
 	} ;
 	chosen {
-		bootargs = "console=ttyS0 root=/dev/ram";
+		bootargs = "console=ttyS0,115200 root=/dev/ram";
 		linux,stdout-path = &RS232_Uart_1;
 	} ;
 	cpus {
@@ -257,12 +257,13 @@
 			#size-cells = <1>;
 			compatible = "xlnx,compound";
 			ethernet@81c00000 {
+				#address-cells = < 1 >;
+				#size-cells = < 0 >;
 				compatible = "xlnx,xps-ll-temac-1.01.b";
-				device_type = "network";
 				interrupt-parent = <&xps_intc_0>;
 				interrupts = < 5 2 >;
 				llink-connected = <&DMA0>;
-				local-mac-address = [ 02 00 00 00 00 00 ];
+				local-mac-address = [ 00 00 00 00 00 00 ];
 				reg = < 0x81c00000 0x40 >;
 				xlnx,bus2core-clk-ratio = <1>;
 				xlnx,phy-type = <1>;
@@ -272,6 +273,11 @@
 				xlnx,temac-type = <0>;
 				xlnx,txcsum = <1>;
 				xlnx,txfifo = <0x1000>;
+				phy-handle = < &phy7 >;
+				phy7: phy@7 {
+					compatible = "marvell,88e1111";
+					reg = <7>;
+				};
 			} ;
 		} ;
 		IIC_EEPROM: i2c@81600000 {
@@ -340,7 +346,7 @@
 		RS232_Uart_1: serial@83e00000 {
 			clock-frequency = <100000000>;
 			compatible = "xlnx,xps-uart16550-2.00.b", "ns16550";
-			current-speed = <9600>;
+			current-speed = <115200>;
 			device_type = "serial";
 			interrupt-parent = <&xps_intc_0>;
 			interrupts = < 9 2 >;
diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index eb6411c..0d6c25e 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -160,9 +160,11 @@ static int m88e1111_config_init(struct phy_device *phydev)
 	int temp;
 
 	/* Enable Fiber/Copper auto selection */
+#if 0
 	temp = phy_read(phydev, MII_M1111_PHY_EXT_SR);
 	temp &= ~MII_M1111_HWCFG_FIBER_COPPER_AUTO;
 	phy_write(phydev, MII_M1111_PHY_EXT_SR, temp);
+#endif
 
 	temp = phy_read(phydev, MII_BMCR);
 	temp |= BMCR_RESET;


From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH v5] DT: net: document Ethernet bindings in one place
Date: Tue, 18 Feb 2014 02:41:59 +0300
Message-ID: <201402180242.00796.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch is an attempt to gather the Ethernet related bindings in one file,
like it's done in the MMC and some other subsystems. It should save some of
the trouble of documenting several properties over and over in each binding
document, instead only making reference to the main file.

I have used the Embedded Power Architecture(TM) Platform Requirements (ePAPR)
standard as a base for the properties description, also documenting some ad-hoc
properties that have been introduced over time despite having direct analogs in
ePAPR.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>

---
The patch is against DaveM's 'net-next.git' repo.

Changes in version 5:
- added references to common file in the Broadcom GENET binding;
- resolved reject, refreshed the patch.

Changes in version 4:
- documented "phy-mode" property as a de-facto standard;
- added "phy-device" property to the common file;
- removed "[local-]mac-address" properties being mentioned in cases where they
  were optional.

Changes in version 3:
- noted about the "max-frame-size" property's contradictory definition in ePAPR
  1.1, reformatted the description (forgot to save the file last time).

Changes in version 2:
- restored the mentions of the common properties in the individual bindings, but
  made them reference the common file instead;
- edited some property descriptions in the common file, indicating preferred and  not recommended properties;
- moved the "max-frame-size" property definition to the common file;
- resolved rejects, refreshed the patch.

 Documentation/devicetree/bindings/net/allwinner,sun4i-emac.txt    |    6 --
 Documentation/devicetree/bindings/net/arc_emac.txt                |   11 ----
 Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt       |    9 +--
 Documentation/devicetree/bindings/net/cavium-mix.txt              |    7 --
 Documentation/devicetree/bindings/net/cavium-pip.txt              |    7 --
 Documentation/devicetree/bindings/net/cdns-emac.txt               |    6 --
 Documentation/devicetree/bindings/net/cpsw.txt                    |    5 --
 Documentation/devicetree/bindings/net/davicom-dm9000.txt          |    2 
 Documentation/devicetree/bindings/net/davinci_emac.txt            |    3 -
 Documentation/devicetree/bindings/net/ethernet.txt                |   25 ++++++++++
 Documentation/devicetree/bindings/net/fsl-fec.txt                 |    5 --
 Documentation/devicetree/bindings/net/fsl-tsec-phy.txt            |   13 +----
 Documentation/devicetree/bindings/net/lpc-eth.txt                 |    5 --
 Documentation/devicetree/bindings/net/macb.txt                    |    6 --
 Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt |    6 --
 Documentation/devicetree/bindings/net/marvell-orion-net.txt       |    4 -
 Documentation/devicetree/bindings/net/micrel-ks8851.txt           |    3 -
 Documentation/devicetree/bindings/net/smsc-lan91c111.txt          |    3 -
 Documentation/devicetree/bindings/net/smsc911x.txt                |    5 --
 Documentation/devicetree/bindings/net/stmmac.txt                  |    7 --
 20 files changed, 53 insertions(+), 85 deletions(-)

Index: net-next/Documentation/devicetree/bindings/net/allwinner,sun4i-emac.txt
===================================================================
--- net-next.orig/Documentation/devicetree/bindings/net/allwinner,sun4i-emac.txt
+++ net-next/Documentation/devicetree/bindings/net/allwinner,sun4i-emac.txt
@@ -5,13 +5,9 @@ Required properties:
               "allwinner,sun4i-emac")
 - reg: address and length of the register set for the device.
 - interrupts: interrupt for the device
-- phy: A phandle to a phy node defining the PHY address (as the reg
-  property, a single integer).
+- phy: see ethernet.txt file in the same directory.
 - clocks: A phandle to the reference clock for this device
 
-Optional properties:
-- (local-)mac-address: mac address to be used by this driver
-
 Example:
 
 emac: ethernet@01c0b000 {
Index: net-next/Documentation/devicetree/bindings/net/arc_emac.txt
===================================================================
--- net-next.orig/Documentation/devicetree/bindings/net/arc_emac.txt
+++ net-next/Documentation/devicetree/bindings/net/arc_emac.txt
@@ -6,19 +6,12 @@ Required properties:
 - interrupts: Should contain the EMAC interrupts
 - clock-frequency: CPU frequency. It is needed to calculate and set polling
 period of EMAC.
-- max-speed: Maximum supported data-rate in Mbit/s. In some HW configurations
-bandwidth of external memory controller might be a limiting factor. That's why
-it's required to specify which data-rate is supported on current SoC or FPGA.
-For example if only 10 Mbit/s is supported (10BASE-T) set "10". If 100 Mbit/s is
-supported (100BASE-TX) set "100".
-- phy: PHY device attached to the EMAC via MDIO bus
+- max-speed: see ethernet.txt file in the same directory.
+- phy: see ethernet.txt file in the same directory.
 
 Child nodes of the driver are the individual PHY devices connected to the
 MDIO bus. They must have a "reg" property given the PHY address on the MDIO bus.
 
-Optional properties:
-- mac-address: 6 bytes, mac address
-
 Examples:
 
 	ethernet@c0fc2000 {
Index: net-next/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
===================================================================
--- net-next.orig/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
+++ net-next/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
@@ -7,9 +7,7 @@ Required properties:
 - interrupts: must be two cells, the first cell is the general purpose
   interrupt line, while the second cell is the interrupt for the ring
   RX and TX queues operating in ring mode
-- phy-mode: String, operation mode of the PHY interface. Supported values are
-  "mii", "rgmii", "rgmii-txid", "rev-mii", "moca". Analogous to ePAPR
-  "phy-connection-type" values
+- phy-mode: see ethernet.txt file in the same directory
 - address-cells: should be 1
 - size-cells: should be 1
 
@@ -20,9 +18,8 @@ Optional properties:
 - clock-names: When provided, names of the functional clock phandles, first
   name should be "enet" and second should be "enet-wol".
 
-- phy-handle: A phandle to a phy node defining the PHY address (as the reg
-  property, a single integer), used to describe configurations where a PHY
-  (internal or external) is used.
+- phy-handle: See ethernet.txt file in the same directory; used to describe
+  configurations where a PHY (internal or external) is used.
 
 - fixed-link: When the GENET interface is connected to a MoCA hardware block or
   when operating in a RGMII to RGMII type of connection, or when the MDIO bus is
Index: net-next/Documentation/devicetree/bindings/net/cavium-mix.txt
===================================================================
--- net-next.orig/Documentation/devicetree/bindings/net/cavium-mix.txt
+++ net-next/Documentation/devicetree/bindings/net/cavium-mix.txt
@@ -18,12 +18,7 @@ Properties:
 - interrupts: Two interrupt specifiers.  The first is the MIX
   interrupt routing and the second the routing for the AGL interrupts.
 
-- mac-address: Optional, the MAC address to assign to the device.
-
-- local-mac-address: Optional, the MAC address to assign to the device
-  if mac-address is not specified.
-
-- phy-handle: Optional, a phandle for the PHY device connected to this device.
+- phy-handle: Optional, see ethernet.txt file in the same directory.
 
 Example:
 	ethernet@1070000100800 {
Index: net-next/Documentation/devicetree/bindings/net/cavium-pip.txt
===================================================================
--- net-next.orig/Documentation/devicetree/bindings/net/cavium-pip.txt
+++ net-next/Documentation/devicetree/bindings/net/cavium-pip.txt
@@ -35,12 +35,7 @@ Properties for PIP port which is a child
 
 - reg: The port number within the interface group.
 
-- mac-address: Optional, the MAC address to assign to the device.
-
-- local-mac-address: Optional, the MAC address to assign to the device
-  if mac-address is not specified.
-
-- phy-handle: Optional, a phandle for the PHY device connected to this device.
+- phy-handle: Optional, see ethernet.txt file in the same directory.
 
 Example:
 
Index: net-next/Documentation/devicetree/bindings/net/cdns-emac.txt
===================================================================
--- net-next.orig/Documentation/devicetree/bindings/net/cdns-emac.txt
+++ net-next/Documentation/devicetree/bindings/net/cdns-emac.txt
@@ -6,11 +6,7 @@ Required properties:
   or the generic form: "cdns,emac".
 - reg: Address and length of the register set for the device
 - interrupts: Should contain macb interrupt
-- phy-mode: String, operation mode of the PHY interface.
-  Supported values are: "mii", "rmii".
-
-Optional properties:
-- local-mac-address: 6 bytes, mac address
+- phy-mode: see ethernet.txt file in the same directory.
 
 Examples:
 
Index: net-next/Documentation/devicetree/bindings/net/cpsw.txt
===================================================================
--- net-next.orig/Documentation/devicetree/bindings/net/cpsw.txt
+++ net-next/Documentation/devicetree/bindings/net/cpsw.txt
@@ -28,9 +28,8 @@ Optional properties:
 Slave Properties:
 Required properties:
 - phy_id		: Specifies slave phy id
-- phy-mode		: The interface between the SoC and the PHY (a string
-			  that of_get_phy_mode() can understand)
-- mac-address		: Specifies slave MAC address
+- phy-mode		: See ethernet.txt file in the same directory
+- mac-address		: See ethernet.txt file in the same directory
 
 Optional properties:
 - dual_emac_res_vlan	: Specifies VID to be used to segregate the ports
Index: net-next/Documentation/devicetree/bindings/net/davicom-dm9000.txt
===================================================================
--- net-next.orig/Documentation/devicetree/bindings/net/davicom-dm9000.txt
+++ net-next/Documentation/devicetree/bindings/net/davicom-dm9000.txt
@@ -9,8 +9,6 @@ Required properties:
 - interrupts : interrupt specifier specific to interrupt controller
 
 Optional properties:
-- local-mac-address : A bytestring of 6 bytes specifying Ethernet MAC address
-    to use (from firmware or bootloader)
 - davicom,no-eeprom : Configuration EEPROM is not available
 - davicom,ext-phy : Use external PHY
 
Index: net-next/Documentation/devicetree/bindings/net/davinci_emac.txt
===================================================================
--- net-next.orig/Documentation/devicetree/bindings/net/davinci_emac.txt
+++ net-next/Documentation/devicetree/bindings/net/davinci_emac.txt
@@ -17,9 +17,8 @@ Required properties:
 			  Miscellaneous Interrupt>
 
 Optional properties:
-- phy-handle: Contains a phandle to an Ethernet PHY.
+- phy-handle: See ethernet.txt file in the same directory.
               If absent, davinci_emac driver defaults to 100/FULL.
-- local-mac-address : 6 bytes, mac address
 - ti,davinci-rmii-en: 1 byte, 1 means use RMII
 - ti,davinci-no-bd-ram: boolean, does EMAC have BD RAM?
 
Index: net-next/Documentation/devicetree/bindings/net/ethernet.txt
===================================================================
--- /dev/null
+++ net-next/Documentation/devicetree/bindings/net/ethernet.txt
@@ -0,0 +1,25 @@
+The following properties are common to the Ethernet controllers:
+
+- local-mac-address: array of 6 bytes, specifies the MAC address that was
+  assigned to the network device;
+- mac-address: array of 6 bytes, specifies the MAC address that was last used by
+  the boot program; should be used in cases where the MAC address assigned to
+  the device by the boot program is different from the "local-mac-address"
+  property;
+- max-speed: number, specifies maximum speed in Mbit/s supported by the device;
+- max-frame-size: number, maximum transfer unit (IEEE defined MTU), rather than
+  the maximum frame size (there's contradiction in ePAPR).
+- phy-mode: string, operation mode of the PHY interface; supported values are
+  "mii", "gmii", "sgmii", "tbi", "rev-mii", "rmii", "rgmii", "rgmii-id",
+  "rgmii-rxid", "rgmii-txid", "rtbi", "smii", "xgmii"; this is now a de-facto
+  standard property;
+- phy-connection-type: the same as "phy-mode" property but described in ePAPR;
+- phy-handle: phandle, specifies a reference to a node representing a PHY
+  device; this property is described in ePAPR and so preferred;
+- phy: the same as "phy-handle" property, not recommended for new bindings.
+- phy-device: the same as "phy-handle" property, not recommended for new
+  bindings.
+
+Child nodes of the Ethernet controller are typically the individual PHY devices
+connected via the MDIO bus (sometimes the MDIO bus controller is separate).
+They are described in the phy.txt file in this same directory.
Index: net-next/Documentation/devicetree/bindings/net/fsl-fec.txt
===================================================================
--- net-next.orig/Documentation/devicetree/bindings/net/fsl-fec.txt
+++ net-next/Documentation/devicetree/bindings/net/fsl-fec.txt
@@ -4,12 +4,9 @@ Required properties:
 - compatible : Should be "fsl,<soc>-fec"
 - reg : Address and length of the register set for the device
 - interrupts : Should contain fec interrupt
-- phy-mode : String, operation mode of the PHY interface.
-  Supported values are: "mii", "gmii", "sgmii", "tbi", "rmii",
-  "rgmii", "rgmii-id", "rgmii-rxid", "rgmii-txid", "rtbi", "smii".
+- phy-mode : See ethernet.txt file in the same directory
 
 Optional properties:
-- local-mac-address : 6 bytes, mac address
 - phy-reset-gpios : Should specify the gpio for phy reset
 - phy-reset-duration : Reset duration in milliseconds.  Should present
   only if property "phy-reset-gpios" is available.  Missing the property
Index: net-next/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
===================================================================
--- net-next.orig/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
+++ net-next/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
@@ -38,22 +38,17 @@ Properties:
   - model : Model of the device.  Can be "TSEC", "eTSEC", or "FEC"
   - compatible : Should be "gianfar"
   - reg : Offset and length of the register set for the device
-  - local-mac-address : List of bytes representing the ethernet address of
-    this controller
   - interrupts : For FEC devices, the first interrupt is the device's
     interrupt.  For TSEC and eTSEC devices, the first interrupt is
     transmit, the second is receive, and the third is error.
-  - phy-handle : The phandle for the PHY connected to this ethernet
-    controller.
+  - phy-handle : See ethernet.txt file in the same directory.
   - fixed-link : <a b c d e> where a is emulated phy id - choose any,
     but unique to the all specified fixed-links, b is duplex - 0 half,
     1 full, c is link speed - d#10/d#100/d#1000, d is pause - 0 no
     pause, 1 pause, e is asym_pause - 0 no asym_pause, 1 asym_pause.
-  - phy-connection-type : a string naming the controller/PHY interface type,
-    i.e., "mii" (default), "rmii", "gmii", "rgmii", "rgmii-id", "sgmii",
-    "tbi", or "rtbi".  This property is only really needed if the connection
-    is of type "rgmii-id", as all other connection types are detected by
-    hardware.
+  - phy-connection-type : See ethernet.txt file in the same directory.
+    This property is only really needed if the connection is of type
+    "rgmii-id", as all other connection types are detected by hardware.
   - fsl,magic-packet : If present, indicates that the hardware supports
     waking up via magic packet.
   - bd-stash : If present, indicates that the hardware supports stashing
Index: net-next/Documentation/devicetree/bindings/net/lpc-eth.txt
===================================================================
--- net-next.orig/Documentation/devicetree/bindings/net/lpc-eth.txt
+++ net-next/Documentation/devicetree/bindings/net/lpc-eth.txt
@@ -6,10 +6,9 @@ Required properties:
 - interrupts: Should contain ethernet controller interrupt
 
 Optional properties:
-- phy-mode: String, operation mode of the PHY interface.
-  Supported values are: "mii", "rmii" (default)
+- phy-mode: See ethernet.txt file in the same directory. If the property is
+  absent, "rmii" is assumed.
 - use-iram: Use LPC32xx internal SRAM (IRAM) for DMA buffering
-- local-mac-address : 6 bytes, mac address
 
 Example:
 
Index: net-next/Documentation/devicetree/bindings/net/macb.txt
===================================================================
--- net-next.orig/Documentation/devicetree/bindings/net/macb.txt
+++ net-next/Documentation/devicetree/bindings/net/macb.txt
@@ -8,16 +8,12 @@ Required properties:
   the Cadence GEM, or the generic form: "cdns,gem".
 - reg: Address and length of the register set for the device
 - interrupts: Should contain macb interrupt
-- phy-mode: String, operation mode of the PHY interface.
-  Supported values are: "mii", "rmii", "gmii", "rgmii".
+- phy-mode: See ethernet.txt file in the same directory.
 - clock-names: Tuple listing input clock names.
 	Required elements: 'pclk', 'hclk'
 	Optional elements: 'tx_clk'
 - clocks: Phandles to input clocks.
 
-Optional properties:
-- local-mac-address: 6 bytes, mac address
-
 Examples:
 
 	macb0: ethernet@fffc4000 {
Index: net-next/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
===================================================================
--- net-next.orig/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
+++ net-next/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
@@ -4,10 +4,8 @@ Required properties:
 - compatible: should be "marvell,armada-370-neta".
 - reg: address and length of the register set for the device.
 - interrupts: interrupt for the device
-- phy: A phandle to a phy node defining the PHY address (as the reg
-  property, a single integer).
-- phy-mode: The interface between the SoC and the PHY (a string that
-  of_get_phy_mode() can understand)
+- phy: See ethernet.txt file in the same directory.
+- phy-mode: See ethernet.txt file in the same directory
 - clocks: a pointer to the reference clock for this device.
 
 Example:
Index: net-next/Documentation/devicetree/bindings/net/marvell-orion-net.txt
===================================================================
--- net-next.orig/Documentation/devicetree/bindings/net/marvell-orion-net.txt
+++ net-next/Documentation/devicetree/bindings/net/marvell-orion-net.txt
@@ -36,7 +36,7 @@ Required port properties:
       "marvell,kirkwood-eth-port".
  - reg: port number relative to ethernet controller, shall be 0, 1, or 2.
  - interrupts: port interrupt.
- - local-mac-address: 6 bytes MAC address.
+ - local-mac-address: See ethernet.txt file in the same directory.
 
 Optional port properties:
  - marvell,tx-queue-size: size of the transmit ring buffer.
@@ -48,7 +48,7 @@ Optional port properties:
 
 and
 
- - phy-handle: phandle reference to ethernet PHY.
+ - phy-handle: See ethernet.txt file in the same directory.
 
 or
 
Index: net-next/Documentation/devicetree/bindings/net/micrel-ks8851.txt
===================================================================
--- net-next.orig/Documentation/devicetree/bindings/net/micrel-ks8851.txt
+++ net-next/Documentation/devicetree/bindings/net/micrel-ks8851.txt
@@ -4,6 +4,3 @@ Required properties:
 - compatible = "micrel,ks8851-ml" of parallel interface
 - reg : 2 physical address and size of registers for data and command
 - interrupts : interrupt connection
-
-Optional properties:
-- local-mac-address : Ethernet mac address to use
Index: net-next/Documentation/devicetree/bindings/net/smsc-lan91c111.txt
===================================================================
--- net-next.orig/Documentation/devicetree/bindings/net/smsc-lan91c111.txt
+++ net-next/Documentation/devicetree/bindings/net/smsc-lan91c111.txt
@@ -6,8 +6,7 @@ Required properties:
 - interrupts : interrupt connection
 
 Optional properties:
-- phy-device : phandle to Ethernet phy
-- local-mac-address : Ethernet mac address to use
+- phy-device : see ethernet.txt file in the same directory
 - reg-io-width : Mask of sizes (in bytes) of the IO accesses that
   are supported on the device.  Valid value for SMSC LAN91c111 are
   1, 2 or 4.  If it's omitted or invalid, the size would be 2 meaning
Index: net-next/Documentation/devicetree/bindings/net/smsc911x.txt
===================================================================
--- net-next.orig/Documentation/devicetree/bindings/net/smsc911x.txt
+++ net-next/Documentation/devicetree/bindings/net/smsc911x.txt
@@ -6,9 +6,7 @@ Required properties:
 - interrupts : Should contain SMSC LAN interrupt line
 - interrupt-parent : Should be the phandle for the interrupt controller
   that services interrupts for this device
-- phy-mode : String, operation mode of the PHY interface.
-  Supported values are: "mii", "gmii", "sgmii", "tbi", "rmii",
-  "rgmii", "rgmii-id", "rgmii-rxid", "rgmii-txid", "rtbi", "smii".
+- phy-mode : See ethernet.txt file in the same directory
 
 Optional properties:
 - reg-shift : Specify the quantity to shift the register offsets by
@@ -23,7 +21,6 @@ Optional properties:
   external PHY
 - smsc,save-mac-address : Indicates that mac address needs to be saved
   before resetting the controller
-- local-mac-address : 6 bytes, mac address
 
 Examples:
 
Index: net-next/Documentation/devicetree/bindings/net/stmmac.txt
===================================================================
--- net-next.orig/Documentation/devicetree/bindings/net/stmmac.txt
+++ net-next/Documentation/devicetree/bindings/net/stmmac.txt
@@ -10,8 +10,7 @@ Required properties:
 - interrupt-names: Should contain the interrupt names "macirq"
   "eth_wake_irq" if this interrupt is supported in the "interrupts"
   property
-- phy-mode: String, operation mode of the PHY interface.
-  Supported values are: "mii", "rmii", "gmii", "rgmii".
+- phy-mode: See ethernet.txt file in the same directory.
 - snps,reset-gpio 	gpio number for phy reset.
 - snps,reset-active-low boolean flag to indicate if phy reset is active low.
 - snps,reset-delays-us  is triplet of delays
@@ -28,12 +27,10 @@ Required properties:
 				ignored if force_thresh_dma_mode is set.
 
 Optional properties:
-- mac-address: 6 bytes, mac address
 - resets: Should contain a phandle to the STMMAC reset signal, if any
 - reset-names: Should contain the reset signal name "stmmaceth", if a
 	reset phandle is given
-- max-frame-size:	Maximum Transfer Unit (IEEE defined MTU), rather
-			than the maximum frame size.
+- max-frame-size: See ethernet.txt file in the same directory
 
 Examples:
 
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

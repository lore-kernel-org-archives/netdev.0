From: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: [PATCHv2 net-next 01/16] dt-bindings: net: update Marvell PPv2 binding for PPv2.2 support
Date: Wed, 28 Dec 2016 17:46:17 +0100
Message-ID: <1482943592-12556-2-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1482943592-12556-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Nadav Haklai <nadavh-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Hanna Hawa <hannah-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Yehuda Yitschak <yehuday-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Stefan Chulski <stefanc-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Marcin Wojtas <mw-nYOzD4b6Jr9Wk0Htik3J/w@public.gmane.org>,
        Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
        Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1482943592-12556-1-git-send-email-thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The Marvell PPv2 Device Tree binding was so far only used to describe
the PPv2.1 network controller, used in the Marvell Armada 375.

A new version of this IP block, PPv2.2 is used in the Marvell Armada
7K/8K processor. This commit extends the existing binding so that it can
also be used to describe PPv2.2 hardware.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
---
 .../devicetree/bindings/net/marvell-pp2.txt        | 66 ++++++++++++++++++----
 1 file changed, 55 insertions(+), 11 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/marvell-pp2.txt b/Documentation/devicetree/bindings/net/marvell-pp2.txt
index aa4f423..76071f3 100644
--- a/Documentation/devicetree/bindings/net/marvell-pp2.txt
+++ b/Documentation/devicetree/bindings/net/marvell-pp2.txt
@@ -1,17 +1,28 @@
-* Marvell Armada 375 Ethernet Controller (PPv2)
+* Marvell Armada 375 Ethernet Controller (PPv2.1)
+  Marvell Armada 7K/8K Ethernet Controller (PPv2.2)
 
 Required properties:
 
-- compatible: should be "marvell,armada-375-pp2"
+- compatible: should be one of:
+    "marvell,armada-375-pp2"
+    "marvell,armada-7k-pp2"
 - reg: addresses and length of the register sets for the device.
-  Must contain the following register sets:
+  For "marvell,armada-375-pp2", must contain the following register
+  sets:
 	- common controller registers
 	- LMS registers
-  In addition, at least one port register set is required.
-- clocks: a pointer to the reference clocks for this device, consequently:
-	- main controller clock
-	- GOP clock
-- clock-names: names of used clocks, must be "pp_clk" and "gop_clk".
+	- one register area per Ethernet port
+  For "marvell,armda-7k-pp2", must contain the following register
+  sets:
+        - common controller registers
+	- per-port registers
+
+- clocks: pointers to the reference clocks for this device, consequently:
+	- main controller clock (for both armada-375-pp2 and armada-7k-pp2)
+	- GOP clock (for both armada-375-pp2 and armada-7k-pp2)
+	- MG clock (only for armada-7k-pp2)
+- clock-names: names of used clocks, must be "pp_clk", "gop_clk" and
+  "mg_clk" (the latter only for armada-7k-pp2).
 
 The ethernet ports are represented by subnodes. At least one port is
 required.
@@ -19,8 +30,9 @@ required.
 Required properties (port):
 
 - interrupts: interrupt for the port
-- port-id: should be '0' or '1' for ethernet ports, and '2' for the
-           loopback port
+- port-id: ID of the port from the MAC point of view
+- gop-port-id: only for marvell,armada-7k-pp2, ID of the port from the
+  GOP (Group Of Ports) point of view
 - phy-mode: See ethernet.txt file in the same directory
 
 Optional properties (port):
@@ -31,7 +43,7 @@ Optional properties (port):
   then fixed link is assumed, and the 'fixed-link' property is
   mandatory.
 
-Example:
+Example for marvell,armada-375-pp2:
 
 ethernet@f0000 {
 	compatible = "marvell,armada-375-pp2";
@@ -59,3 +71,35 @@ ethernet@f0000 {
 		phy-mode = "gmii";
 	};
 };
+
+Example for marvell,armada-7k-pp2:
+
+cpm_ethernet: ethernet@0 {
+	compatible = "marvell,armada-7k-pp22";
+	reg = <0x0 0x100000>,
+	      <0x100000 0x80000>;
+	clocks = <&cpm_syscon0 1 3>, <&cpm_syscon0 1 9>, <&cpm_syscon0 1 5>;
+	clock-names = "pp_clk", "gop_clk", "gp_clk";
+	status = "disabled";
+
+	eth0: eth@0 {
+		interrupts = <GIC_SPI 37 IRQ_TYPE_LEVEL_HIGH>;
+		port-id = <0>;
+		gop-port-id = <0>;
+		status = "disabled";
+	};
+
+	eth1: eth@1 {
+		interrupts = <GIC_SPI 38 IRQ_TYPE_LEVEL_HIGH>;
+		port-id = <1>;
+		gop-port-id = <2>;
+		status = "disabled";
+	};
+
+	eth2: eth@2 {
+		interrupts = <GIC_SPI 39 IRQ_TYPE_LEVEL_HIGH>;
+		port-id = <2>;
+		gop-port-id = <3>;
+		status = "disabled";
+	};
+};
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

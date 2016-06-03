From: Pramod Kumar <pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v3 RESEND 3/7] binding: mdio-mux: Add DT binding doc for Broadcom MDIO bus mutiplexer
Date: Fri,  3 Jun 2016 21:33:02 +0530
Message-ID: <1464969786-22742-4-git-send-email-pramod.kumar@broadcom.com>
References: <1464969786-22742-1-git-send-email-pramod.kumar@broadcom.com>
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Pramod Kumar <pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
	Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1464969786-22742-1-git-send-email-pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add DT binding doc for Broadcom MDIO bus mutiplexer driver.

Signed-off-by: Pramod Kumar <pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
---
 .../bindings/net/brcm,mdio-mux-iproc.txt           | 59 ++++++++++++++++++++++
 1 file changed, 59 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt

diff --git a/Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt b/Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt
new file mode 100644
index 0000000..7c53278
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt
@@ -0,0 +1,59 @@
+Properties for an MDIO bus mutiplexer found in Broadcom iProc based SoCs.
+
+This MDIO bus multiplexer defines buses that could be internal as well as
+external to SoCs and could accept MDIO transaction compatible to C-22 or
+C-45 Clause. When child bus is selected, one needs to select these two
+properties as well to generate desired MDIO trascation on appropriate bus.
+
+Required properties in addition to the generic multiplexer properties:
+
+MDIO multiplexer node:
+- compatible: brcm,mdio-mux-iproc.
+
+Every non-ethernet PHY requires a compatible so that it could be probed based
+on this compatible string.
+
+Additional information regarding generic multiplexer properties can be found
+at- Documentation/devicetree/bindings/net/mdio-mux.txt
+
+
+for example:
+		mdio_mux_iproc: mdio-mux@6602023c {
+			compatible = "brcm,mdio-mux-iproc";
+			reg = <0x6602023c 0x14>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			mdio@0 {
+				reg = <0x0>;
+				#address-cells = <1>;
+				#size-cells = <0>;
+
+				pci_phy0: pci-phy@0 {
+					compatible = "brcm,ns2-pcie-phy";
+					reg = <0x0>;
+					#phy-cells = <0>;
+				};
+			};
+
+			mdio@7 {
+				reg = <0x7>;
+				#address-cells = <1>;
+				#size-cells = <0>;
+
+				pci_phy1: pci-phy@0 {
+					compatible = "brcm,ns2-pcie-phy";
+					reg = <0x0>;
+					#phy-cells = <0>;
+				};
+			};
+			mdio@10 {
+				reg = <0x10>;
+				#address-cells = <1>;
+				#size-cells = <0>;
+
+				gphy0: eth-phy@10 {
+					reg = <0x10>;
+				};
+			};
+		};
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

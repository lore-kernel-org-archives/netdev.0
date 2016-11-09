From: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
Subject: [PATCH 2/6] dt-bindings: phy: Add documentation for NSP USB3 PHY
Date: Wed,  9 Nov 2016 04:33:10 -0500
Message-ID: <1478683994-12008-3-git-send-email-yendapally.reddy@broadcom.com>
References: <1478683994-12008-1-git-send-email-yendapally.reddy@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org,
 Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>,
 bcm-kernel-feedback-list@broadcom.com, linux-arm-kernel@lists.infradead.org
To: Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>,
 Russell King <linux@armlinux.org.uk>, Ray Jui <rjui@broadcom.com>,
 Scott Branden <sbranden@broadcom.com>, Jon Mason <jonmason@broadcom.com>,
 Florian Fainelli <f.fainelli@gmail.com>,
 Kishon Vijay Abraham I <kishon@ti.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1478683994-12008-1-git-send-email-yendapally.reddy@broadcom.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Add documentation for USB3 PHY available in Northstar plus SoC

Signed-off-by: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
---
 .../devicetree/bindings/phy/brcm,nsp-usb3-phy.txt  | 39 ++++++++++++++++++++++
 1 file changed, 39 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/phy/brcm,nsp-usb3-phy.txt

diff --git a/Documentation/devicetree/bindings/phy/brcm,nsp-usb3-phy.txt b/Documentation/devicetree/bindings/phy/brcm,nsp-usb3-phy.txt
new file mode 100644
index 0000000..30cf4b9
--- /dev/null
+++ b/Documentation/devicetree/bindings/phy/brcm,nsp-usb3-phy.txt
@@ -0,0 +1,39 @@
+Broadcom USB3 phy binding northstar plus SoC
+This is a child bus node of "brcm,mdio-mux-nsp" node.
+
+Required mdio bus properties:
+- reg: MDIO Bus number for the MDIO interface
+- #address-cells: must be 1
+- #size-cells: must be 0
+
+Required PHY properties:
+- compatible: should be "brcm,nsp-usb3-phy"
+- reg: Phy address in the MDIO interface
+- usb3-ctrl-syscon: handler of syscon node defining physical address
+  of usb3 control register.
+- #phy-cells: must be 0
+
+Required usb3 control properties:
+- compatible: should be "brcm,nsp-usb3-ctrl"
+- reg: offset and length of the control registers
+
+Example:
+
+	mdio@0 {
+		reg = <0x0>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		usb3_phy: usb3-phy@10 {
+			compatible = "brcm,nsp-usb3-phy";
+			reg = <0x10>;
+			usb3-ctrl-syscon = <&usb3_ctrl>;
+			#phy-cells = <0>;
+			status = "disabled";
+		};
+	}
+
+	usb3_ctrl: syscon@104408 {
+		compatible = "brcm,nsp-usb3-ctrl", "syscon";
+		reg = <0x104408 0x3fc>;
+	};
-- 
2.1.0

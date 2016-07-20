From: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 3/5] ARM: sun8i: dt: Add DT bindings
 documentation for Allwinner sun8i-emac
Date: Wed, 20 Jul 2016 10:03:18 +0200
Message-ID: <1469001800-11615-4-git-send-email-clabbe.montjoie@gmail.com>
References: <1469001800-11615-1-git-send-email-clabbe.montjoie@gmail.com>
Reply-To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org,
	maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	wens-jdAy2FN1RRM@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-sunxi+bncBD7YLCN32UNBBYXAXS6AKGQEIYQAVBI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <1469001800-11615-1-git-send-email-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

This patch adds documentation for Device-Tree bindings for the
Allwinner sun8i-emac driver.

Signed-off-by: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 .../bindings/net/allwinner,sun8i-emac.txt          | 65 ++++++++++++++++++++++
 1 file changed, 65 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/allwinner,sun8i-emac.txt

diff --git a/Documentation/devicetree/bindings/net/allwinner,sun8i-emac.txt b/Documentation/devicetree/bindings/net/allwinner,sun8i-emac.txt
new file mode 100644
index 0000000..4bf4e53
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/allwinner,sun8i-emac.txt
@@ -0,0 +1,65 @@
+* Allwinner sun8i EMAC ethernet controller
+
+Required properties:
+- compatible: "allwinner,sun8i-a83t-emac", "allwinner,sun8i-h3-emac",
+		or "allwinner,sun50i-a64-emac"
+- reg: address and length of the register sets for the device.
+- reg-names: should be "emac" and "syscon", matching the register sets
+- interrupts: interrupt for the device
+- clocks: A phandle to the reference clock for this device
+- clock-names: should be "ahb"
+- resets: A phandle to the reset control for this device
+- reset-names: should be "ahb"
+- phy-mode: See ethernet.txt
+- phy or phy-handle: See ethernet.txt
+- #address-cells: shall be 1
+- #size-cells: shall be 0
+
+"allwinner,sun8i-h3-emac" also requires:
+- clocks: an extra phandle to the reference clock for the EPHY
+- clock-names: an extra "ephy" entry matching the clocks property
+- resets: an extra phandle to the reset control for the EPHY
+- resets-names: an extra "ephy" entry matching the resets property
+
+See ethernet.txt in the same directory for generic bindings for ethernet
+controllers.
+
+The device node referenced by "phy" or "phy-handle" should be a child node
+of this node. See phy.txt for the generic PHY bindings.
+
+Optional properties:
+- phy-supply: phandle to a regulator if the PHY needs one
+- phy-io-supply: phandle to a regulator if the PHY needs a another one for I/O.
+		 This is sometimes found with RGMII PHYs, which use a second
+		 regulator for the lower I/O voltage.
+- allwinner,tx-delay: The setting of the TX clock delay chain
+- allwinner,rx-delay: The setting of the RX clock delay chain
+
+The TX/RX clock delay chain settings are board specific.
+
+Optional properties for "allwinner,sun8i-h3-emac":
+- allwinner,use-internal-phy: Use the H3 SoC's internal E(thernet) PHY
+- allwinner,leds-active-low: EPHY LEDs are active low
+
+When the internal PHY is requested, the implementation shall configure the
+internal PHY to use the address specified in the child PHY node.
+
+Example:
+
+emac: ethernet@01c0b000 {
+	compatible = "allwinner,sun8i-h3-emac";
+	reg = <0x01c0b000 0x104>, <0x01c00030 0x4>;
+	reg-names = "emac", "syscon";
+	interrupts = <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
+	clocks = <&bus_gates 17>, <&bus_gates 128>;
+	clock-names = "ahb", "ephy";
+	resets = <&ahb_rst 17>, <&ahb_rst 66>;
+	reset-names = "ahb", "ephy";
+	phy = <&phy1>;
+	allwinner,use-internal-phy;
+	allwinner,leds-active-low;
+
+	phy1: ethernet-phy@1 {
+		reg = <1>;
+	};
+};
-- 
2.7.3

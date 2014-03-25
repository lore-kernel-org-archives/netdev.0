From: <dinguyen@altera.com>
Subject: [PATCH 3/3] dts: documentation: Update documentation for the stmmac
 ethernet controller
Date: Tue, 25 Mar 2014 18:34:42 -0500
Message-ID: <1395790482-3957-4-git-send-email-dinguyen@altera.com>
References: <1395790482-3957-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, devicetree@vger.kernel.org, pawel.moll@arm.com,
 srinivas.kandagatla@st.com, netdev@vger.kernel.org,
 ijc+devicetree@hellion.org.uk, robh+dt@kernel.org, arm@kernel.org,
 Dinh Nguyen <dinguyen@altera.com>, galak@codeaurora.org,
 linux-arm-kernel@lists.infradead.org
To: <dinh.linux@gmail.com>, <arnd@arndb.de>, <davem@davemloft.net>,
 <peppe.cavallaro@st.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1395790482-3957-1-git-send-email-dinguyen@altera.com>
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

From: Dinh Nguyen <dinguyen@altera.com>

* Add optional clocks and clock-names property into the base stmmac document.
* Update socfpga-dwmac.txt with new compatible string and example binding.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Dinh Nguyen <dinguyen@altera.com>
---
 .../devicetree/bindings/net/socfpga-dwmac.txt      |   38 ++++++++------------
 Documentation/devicetree/bindings/net/stmmac.txt   |    6 ++++
 2 files changed, 21 insertions(+), 23 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
index d53d376..1ef6db7 100644
--- a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
+++ b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
@@ -1,35 +1,27 @@
 Altera SOCFPGA SoC DWMAC controller
 
-The device node has following properties.
+This is a variant of the dwmac/stmmac driver an inherits all descriptions
+present in Documentation/devicetree/bindings/net/stmmac.txt.
+
+The device node has additional properties:
 
 Required properties:
- - compatible	: Should contain "altr,socfpga-stmmac"
+ - compatible	: Should contain "altr,socfpga-stmmac" along with
+		  "snps,dwmac" and any applicable more detailed
+		  designware version numbers documented in stmmac.txt
  - altr,sysmgr-syscon : Should be the phandle to the system manager node that
    encompasses the glue register, and the register offset.
 
-Sub-nodes:
-The dwmac core should be added as subnode to SOCFPGA dwmac glue.
-- dwmac :	The binding details of dwmac can be found in
-  Documentation/devicetree/bindings/net/stmmac.txt
-
 Example:
 
-ethernet0: ethernet0 {
-	#address-cells = <1>;
-	#size-cells = <1>;
-
-	compatible = "altr,socfpga-stmmac";
+gmac0: ethernet@ff700000 {
+	compatible = "altr,socfpga-stmmac", "snps,dwmac-3.70a", "snps,dwmac";
 	altr,sysmgr-syscon = <&sysmgr 0x60>;
 	status = "disabled";
-	ranges;
-
-	gmac0: gmac0@ff700000 {
-		compatible = "snps,dwmac-3.70a", "snps,dwmac";
-		reg = <0xff700000 0x2000>;
-		interrupts = <0 115 4>;
-		interrupt-names = "macirq";
-		mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
-		clocks = <&emac0_clk>;
-		clock-names = "stmmaceth";
-	};
+	reg = <0xff700000 0x2000>;
+	interrupts = <0 115 4>;
+	interrupt-names = "macirq";
+	mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
+	clocks = <&emac0_clk>;
+	clocks-names = "stmmaceth";
 };
diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index 9d92d42..9a0c1b7 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -34,6 +34,10 @@ Optional properties:
 	reset phandle is given
 - max-frame-size:	Maximum Transfer Unit (IEEE defined MTU), rather
 			than the maximum frame size.
+- clocks: If present, the first clock should be the GMAC main clock,
+  further clocks may be specified in derived bindings.
+- clocks-names: One name for each entry in the clocks property, the
+  first one should be "stmmaceth".
 
 Examples:
 
@@ -46,4 +50,6 @@ Examples:
 		mac-address = [000000000000]; /* Filled in by U-Boot */
 		max-frame-size = <3800>;
 		phy-mode = "gmii";
+		clocks = <&clock>;
+		clock-names = "stmmaceth">;
 	};
-- 
1.7.9.5

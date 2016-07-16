From: Jamie Lentin <jm@lentin.co.uk>
Subject: [PATCH v0 04/10] arm: orion5x: Generalise mv88f5181l pinctrl support
 for 88f5181
Date: Sat, 16 Jul 2016 15:29:02 +0100
Message-ID: <1468679348-10522-5-git-send-email-jm@lentin.co.uk>
References: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, Jamie Lentin <jm@lentin.co.uk>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 netdev@vger.kernel.org
To: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Imre Kaloz <kaloz@openwrt.org>, Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
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

As far as I'm aware the mv88f5181-b1 and mv88f5181l are the same at the
pinctrl level, so re-use the definitions for both.

Signed-off-by: Jamie Lentin <jm@lentin.co.uk>
---
 .../bindings/pinctrl/marvell,orion-pinctrl.txt     |  4 ++--
 drivers/pinctrl/mvebu/pinctrl-orion.c              | 23 +++++++++++-----------
 2 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/Documentation/devicetree/bindings/pinctrl/marvell,orion-pinctrl.txt b/Documentation/devicetree/bindings/pinctrl/marvell,orion-pinctrl.txt
index 27570a3..5a79bad 100644
--- a/Documentation/devicetree/bindings/pinctrl/marvell,orion-pinctrl.txt
+++ b/Documentation/devicetree/bindings/pinctrl/marvell,orion-pinctrl.txt
@@ -4,8 +4,8 @@ Please refer to marvell,mvebu-pinctrl.txt in this directory for common binding
 part and usage.
 
 Required properties:
-- compatible: "marvell,88f5181l-pinctrl", "marvell,88f5182-pinctrl",
-              "marvell,88f5281-pinctrl"
+- compatible: "marvell,88f5181-pinctrl", "marvell,88f5181l-pinctrl",
+              "marvell,88f5182-pinctrl", "marvell,88f5281-pinctrl"
 
 - reg: two register areas, the first one describing the first two
   contiguous MPP registers, and the second one describing the single
diff --git a/drivers/pinctrl/mvebu/pinctrl-orion.c b/drivers/pinctrl/mvebu/pinctrl-orion.c
index 3b7122d..6f9c8ee 100644
--- a/drivers/pinctrl/mvebu/pinctrl-orion.c
+++ b/drivers/pinctrl/mvebu/pinctrl-orion.c
@@ -64,11 +64,11 @@ static int orion_mpp_ctrl_set(unsigned pid, unsigned long config)
 	return 0;
 }
 
-#define V(f5181l, f5182, f5281) \
-	((f5181l << 0) | (f5182 << 1) | (f5281 << 2))
+#define V(f5181, f5182, f5281) \
+	((f5181 << 0) | (f5182 << 1) | (f5281 << 2))
 
 enum orion_variant {
-	V_5181L = V(1, 0, 0),
+	V_5181  = V(1, 0, 0),
 	V_5182  = V(0, 1, 0),
 	V_5281  = V(0, 0, 1),
 	V_ALL   = V(1, 1, 1),
@@ -103,13 +103,13 @@ static struct mvebu_mpp_mode orion_mpp_modes[] = {
 		 MPP_VAR_FUNCTION(0x0, "gpio", NULL,        V_ALL),
 		 MPP_VAR_FUNCTION(0x2, "pci", "req5",       V_ALL),
 		 MPP_VAR_FUNCTION(0x4, "nand", "re0",       V_5182 | V_5281),
-		 MPP_VAR_FUNCTION(0x5, "pci-1", "clk",      V_5181L),
+		 MPP_VAR_FUNCTION(0x5, "pci-1", "clk",      V_5181),
 		 MPP_VAR_FUNCTION(0x5, "sata0", "act",      V_5182)),
 	MPP_MODE(7,
 		 MPP_VAR_FUNCTION(0x0, "gpio", NULL,        V_ALL),
 		 MPP_VAR_FUNCTION(0x2, "pci", "gnt5",       V_ALL),
 		 MPP_VAR_FUNCTION(0x4, "nand", "we0",       V_5182 | V_5281),
-		 MPP_VAR_FUNCTION(0x5, "pci-1", "clk",      V_5181L),
+		 MPP_VAR_FUNCTION(0x5, "pci-1", "clk",      V_5181),
 		 MPP_VAR_FUNCTION(0x5, "sata1", "act",      V_5182)),
 	MPP_MODE(8,
 		 MPP_VAR_FUNCTION(0x0, "gpio", NULL,        V_ALL),
@@ -165,7 +165,7 @@ static struct mvebu_mpp_ctrl orion_mpp_controls[] = {
 	MPP_FUNC_CTRL(0, 19, NULL, orion_mpp_ctrl),
 };
 
-static struct pinctrl_gpio_range mv88f5181l_gpio_ranges[] = {
+static struct pinctrl_gpio_range mv88f5181_gpio_ranges[] = {
 	MPP_GPIO_RANGE(0, 0, 0, 16),
 };
 
@@ -177,14 +177,14 @@ static struct pinctrl_gpio_range mv88f5281_gpio_ranges[] = {
 	MPP_GPIO_RANGE(0, 0, 0, 16),
 };
 
-static struct mvebu_pinctrl_soc_info mv88f5181l_info = {
-	.variant = V_5181L,
+static struct mvebu_pinctrl_soc_info mv88f5181_info = {
+	.variant = V_5181,
 	.controls = orion_mpp_controls,
 	.ncontrols = ARRAY_SIZE(orion_mpp_controls),
 	.modes = orion_mpp_modes,
 	.nmodes = ARRAY_SIZE(orion_mpp_modes),
-	.gpioranges = mv88f5181l_gpio_ranges,
-	.ngpioranges = ARRAY_SIZE(mv88f5181l_gpio_ranges),
+	.gpioranges = mv88f5181_gpio_ranges,
+	.ngpioranges = ARRAY_SIZE(mv88f5181_gpio_ranges),
 };
 
 static struct mvebu_pinctrl_soc_info mv88f5182_info = {
@@ -212,7 +212,8 @@ static struct mvebu_pinctrl_soc_info mv88f5281_info = {
  * muxing, they are identical.
  */
 static const struct of_device_id orion_pinctrl_of_match[] = {
-	{ .compatible = "marvell,88f5181l-pinctrl", .data = &mv88f5181l_info },
+	{ .compatible = "marvell,88f5181-pinctrl", .data = &mv88f5181_info },
+	{ .compatible = "marvell,88f5181l-pinctrl", .data = &mv88f5181_info },
 	{ .compatible = "marvell,88f5182-pinctrl", .data = &mv88f5182_info },
 	{ .compatible = "marvell,88f5281-pinctrl", .data = &mv88f5281_info },
 	{ }
-- 
2.8.1

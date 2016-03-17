From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: [PATCH v2] ARC: axs10x - add Ethernet PHY description in .dts
Date: Thu, 17 Mar 2016 12:41:52 +0300
Message-ID: <1458207712-29435-1-git-send-email-abrodkin@synopsys.com>
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	Rob Herring <robh@kernel.org>,
	Phil Reid <preid@electromag.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	stable@vger.kernel.org, #@synopsys.com, 4.5.x@synopsys.com,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: linux-snps-arc@lists.infradead.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Following commit broke DW GMAC functionality on AXS10x boards:
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=e34d65696d2ef13dc32f2a162556c86c461ed763

That's what happens on eth0 up:
--------------------------->8------------------------
libphy: PHY stmmac-0:ffffffff not found
eth0: Could not attach to PHY
stmmac_open: Cannot attach to PHY (error: -19)
--------------------------->8------------------------

Simplest solution is to add PHY description in board's .dts.
And so we do here.

Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>
Cc: Rob Herring <robh@kernel.org>
Cc: Phil Reid <preid@electromag.com.au>
Cc: David S. Miller <davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: stable@vger.kernel.org # 4.5.x
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
---

Changes v1 -> v2:
 * PHY node name changed to match real PHY number being used (Sergei)

 arch/arc/boot/dts/axs10x_mb.dtsi | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/arc/boot/dts/axs10x_mb.dtsi b/arch/arc/boot/dts/axs10x_mb.dtsi
index 44a578c..ab5d570 100644
--- a/arch/arc/boot/dts/axs10x_mb.dtsi
+++ b/arch/arc/boot/dts/axs10x_mb.dtsi
@@ -47,6 +47,14 @@
 			clocks = <&apbclk>;
 			clock-names = "stmmaceth";
 			max-speed = <100>;
+			mdio0 {
+				#address-cells = <1>;
+				#size-cells = <0>;
+				compatible = "snps,dwmac-mdio";
+				phy1: ethernet-phy@1 {
+					reg = <1>;
+				};
+			};
 		};
 
 		ehci@0x40000 {
-- 
2.5.0

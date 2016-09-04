From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [PATCH v4 5/5] ARM64: dts: meson-gxbb: use the new GXBB DWMAC glue
 driver
Date: Sun,  4 Sep 2016 20:23:20 +0200
Message-ID: <20160904182320.671-6-martin.blumenstingl@googlemail.com>
References: <20160828161637.9941-1-martin.blumenstingl@googlemail.com>
 <20160904182320.671-1-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, devicetree@vger.kernel.org, arnd@arndb.de,
 Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
 catalin.marinas@arm.com, manabian@gmail.com, will.deacon@arm.com,
 davem@davemloft.net, robh+dt@kernel.org, netdev@vger.kernel.org,
 sboyd@codeaurora.org, linux-arm-kernel@lists.infradead.org
To: linux-amlogic@lists.infradead.org, khilman@baylibre.com, carlo@caione.org,
 mturquette@baylibre.com, peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20160904182320.671-1-martin.blumenstingl@googlemail.com>
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

The Amlogic reference driver uses the "mc_val" devicetree property to
configure the PRG_ETHERNET_ADDR0 register. Unfortunately it uses magic
values for this configuration.
According to the datasheet the PRG_ETHERNET_ADDR0 register is at address
0xc8834108. However, the reference driver uses 0xc8834540 instead.
According to my tests, the value from the reference driver is correct.

No changes are required to the board dts files because the only
required configuration option is the phy-mode, which had to be
configured correctly before as well.

Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
---
 arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi b/arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi
index 2b47415..2e8a3d9 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi
+++ b/arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi
@@ -497,13 +497,15 @@
 		};
 
 		ethmac: ethernet@c9410000 {
-			compatible = "amlogic,meson6-dwmac", "snps,dwmac";
+			compatible = "amlogic,meson-gxbb-dwmac", "snps,dwmac";
 			reg = <0x0 0xc9410000 0x0 0x10000
 			       0x0 0xc8834540 0x0 0x4>;
 			interrupts = <0 8 1>;
 			interrupt-names = "macirq";
-			clocks = <&clkc CLKID_ETH>;
-			clock-names = "stmmaceth";
+			clocks = <&clkc CLKID_ETH>,
+				 <&clkc CLKID_FCLK_DIV2>,
+				 <&clkc CLKID_MPLL2>;
+			clock-names = "stmmaceth", "clkin0", "clkin1";
 			phy-mode = "rgmii";
 			status = "disabled";
 		};
-- 
2.9.3

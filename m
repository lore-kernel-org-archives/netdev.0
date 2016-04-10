From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.5 155/238] ARC: [plat-axs10x] add Ethernet PHY description in .dts
Date: Sun, 10 Apr 2016 11:35:32 -0700
Message-ID: <20160410183505.028843746@linuxfoundation.org>
References: <20160410183456.398741366@linuxfoundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	stable@vger.kernel.org, Alexey Brodkin <abrodkin@synopsys.com>,
	Rob Herring <robh@kernel.org>,
	Phil Reid <preid@electromag.com.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vineet Gupta <vgupta@synopsys.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160410183456.398741366@linuxfoundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

4.5-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>

commit 667a490bdb6e27db0887d2ca515b907d6aa87118 upstream.

Commit e34d65696d2e ("stmmac: create of compatible mdio bus for stmmac
driver") broke DW GMAC functionality on ARC AXS10x boards:

That's what happens on eth0 up:
  --------------------------->8------------------------
| libphy: PHY stmmac-0:ffffffff not found
| eth0: Could not attach to PHY
| stmmac_open: Cannot attach to PHY (error: -19)
  --------------------------->8------------------------

Simplest solution is to add PHY description in board's .dts.
And so we do here.

Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>
Cc: Rob Herring <robh@kernel.org>
Cc: Phil Reid <preid@electromag.com.au>
Cc: David S. Miller <davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
Reviewed-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/arc/boot/dts/axs10x_mb.dtsi |    8 ++++++++
 1 file changed, 8 insertions(+)

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

From: Jose Abreu <Jose.Abreu@synopsys.com>
Subject: [PATCH net-next 2/2] bindings: net: stmmac: Add documentation for TSN parameters
Date: Wed, 25 Oct 2017 15:04:01 +0100
Message-ID: <ef1d220cf792c74ae278e0200ca4763f9ab62d3e.1508938927.git.joabreu@synopsys.com>
References: <cover.1508938927.git.joabreu@synopsys.com>
Cc: Jose Abreu <Jose.Abreu@synopsys.com>,
        "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Rob Herring <robh+dt@kernel.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1508938927.git.joabreu@synopsys.com>
In-Reply-To: <cover.1508938927.git.joabreu@synopsys.com>
References: <cover.1508938927.git.joabreu@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds the documentation for TSN feature EST and FP.

Signed-off-by: Jose Abreu <joabreu@synopsys.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Joao Pinto <jpinto@synopsys.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Alexandre Torgue <alexandre.torgue@st.com>
Cc: Rob Herring <robh+dt@kernel.org>
---
 Documentation/devicetree/bindings/net/stmmac.txt | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index c3a7be6..6359df6 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -114,6 +114,16 @@ Optional properties:
 			- snps,high_credit: max write outstanding req. limit
 			- snps,low_credit: max read outstanding req. limit
 		- snps,priority: TX queue priority (Range: 0x0 to 0xF)
+- TSN parameters: below the list of all the parameters to configure TSN
+		  features (only applicable for IP version >= 5.00)
+	- snps,est: Enable EST algorithm
+	- If EST enabled provide these parameters:
+		- snps,btr: Array size of 2 with BTR value for EST algorithm
+		- snps,ctr: Array size of 2 with CTR value for EST algorithm
+		- snps,ter: TER value for EST algorithm
+		- snps,gcl: Variable size array with GCL table entries.
+	- snps,fp: Enable FP feature. This needs EST enabled.
+
 Examples:
 
 	stmmac_axi_setup: stmmac-axi-config {
@@ -151,6 +161,15 @@ Examples:
 		};
 	};
 
+	tsn_setup: tsn-config {
+		snps,est;
+		snps,btr = <0x00000000 0x00000001>;
+		snps,ctr = <0x00000000 0x10000000>;
+		snps,ter = <0x00000000>;
+		snps,gcl = <0x00000001 0x00000002 0x00000003>;
+		snps,fp;
+	};
+
 	gmac0: ethernet@e0800000 {
 		compatible = "st,spear600-gmac";
 		reg = <0xe0800000 0x8000>;
@@ -176,4 +195,5 @@ Examples:
 		};
 		snps,mtl-rx-config = <&mtl_rx_setup>;
 		snps,mtl-tx-config = <&mtl_tx_setup>;
+		snps,tsn-config = <&tsn_setup>;
 	};
-- 
1.9.1

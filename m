From: Thierry Reding <thierry.reding@gmail.com>
Subject: [PATCH 1/7] net: stmmac: Rename clk_ptp_ref clock to ptp_ref
Date: Thu, 23 Feb 2017 18:24:32 +0100
Message-ID: <20170223172438.14770-2-thierry.reding@gmail.com>
References: <20170223172438.14770-1-thierry.reding@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Alexandre Courbot <gnurou@gmail.com>,
        Jon Hunter <jonathanh@nvidia.com>, netdev@vger.kernel.org,
        linux-tegra@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170223172438.14770-1-thierry.reding@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

There aren't currently any users of the "clk_ptp_ref", but there are
other references to "ptp_ref", so I'm leaning towards considering that a
typo. Fix it.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
 Documentation/devicetree/bindings/net/stmmac.txt      | 6 +++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index d3bfc2b30fb5..11b27dfd1627 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -28,9 +28,9 @@ Optional properties:
   clocks may be specified in derived bindings.
 - clock-names: One name for each entry in the clocks property, the
   first one should be "stmmaceth" and the second one should be "pclk".
-- clk_ptp_ref: this is the PTP reference clock; in case of the PTP is
-  available this clock is used for programming the Timestamp Addend Register.
-  If not passed then the system clock will be used and this is fine on some
+- ptp_ref: this is the PTP reference clock; in case of the PTP is available
+  this clock is used for programming the Timestamp Addend Register. If not
+  passed then the system clock will be used and this is fine on some
   platforms.
 - tx-fifo-depth: See ethernet.txt file in the same directory
 - rx-fifo-depth: See ethernet.txt file in the same directory
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 433a84239a68..5b18355c0d2b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -359,7 +359,7 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 	clk_prepare_enable(plat->pclk);
 
 	/* Fall-back to main clock in case of no PTP ref is passed */
-	plat->clk_ptp_ref = devm_clk_get(&pdev->dev, "clk_ptp_ref");
+	plat->clk_ptp_ref = devm_clk_get(&pdev->dev, "ptp_ref");
 	if (IS_ERR(plat->clk_ptp_ref)) {
 		plat->clk_ptp_rate = clk_get_rate(plat->stmmac_clk);
 		plat->clk_ptp_ref = NULL;
-- 
2.11.1

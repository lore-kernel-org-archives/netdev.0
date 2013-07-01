From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [PATCH RFC 1/3] dt:net:stmmac: Allocate platform data only if its NULL.
Date: Mon,  1 Jul 2013 12:43:44 +0100
Message-ID: <1372679024-13089-1-git-send-email-srinivas.kandagatla@st.com>
References: <1372678962-12959-1-git-send-email-srinivas.kandagatla@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Rob Landley <rob@landley.net>,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372678962-12959-1-git-send-email-srinivas.kandagatla@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

In some DT use-cases platform data might be already allocated and passed
via AUXDATA. These are the cases where machine level code populates few
callbacks in the platform data.

This patch adds check and reuses platform_data if its valid, before
allocating a new one.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 1d3780f..5907920 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -92,8 +92,10 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 	if (IS_ERR(addr))
 		return PTR_ERR(addr);
 
+	plat_dat = pdev->dev.platform_data;
 	if (pdev->dev.of_node) {
-		plat_dat = devm_kzalloc(&pdev->dev,
+		if (!plat_dat)
+			plat_dat = devm_kzalloc(&pdev->dev,
 					sizeof(struct plat_stmmacenet_data),
 					GFP_KERNEL);
 		if (!plat_dat) {
@@ -106,8 +108,6 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 			pr_err("%s: main dt probe failed", __func__);
 			return ret;
 		}
-	} else {
-		plat_dat = pdev->dev.platform_data;
 	}
 
 	/* Custom initialisation (if needed)*/
-- 
1.7.6.5

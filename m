From: Srinivas KANDAGATLA <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>
Subject: [PATCH v1 1/3] dt:net:stmmac: Allocate platform data only if its NULL.
Date: Tue,  2 Jul 2013 14:04:23 +0100
Message-ID: <1372770263-1720-1-git-send-email-srinivas.kandagatla@st.com>
References: <1372770219-1643-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 Srinivas Kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>, Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
 Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1372770219-1643-1-git-send-email-srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Srinivas Kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>

In some DT use-cases platform data might be already allocated and passed
via AUXDATA. These are the cases where machine level code populates few
callbacks in the platform data.

This patch adds check and reuses platform_data if its valid, before
allocating a new one.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
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

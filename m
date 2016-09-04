From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [PATCH v4 3/5] stmmac: introduce get_stmmac_bsp_priv() helper
Date: Sun,  4 Sep 2016 20:23:18 +0200
Message-ID: <20160904182320.671-4-martin.blumenstingl@googlemail.com>
References: <20160828161637.9941-1-martin.blumenstingl@googlemail.com>
 <20160904182320.671-1-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, devicetree@vger.kernel.org, arnd@arndb.de,
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

From: Joachim Eastwood <manabian@gmail.com>

Create a helper to retrive dwmac private data from a dev
pointer. This is useful in PM callbacks and driver remove.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
Tested-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Acked-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
index ffeb8d9..64e147f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
@@ -30,4 +30,12 @@ int stmmac_get_platform_resources(struct platform_device *pdev,
 int stmmac_pltfr_remove(struct platform_device *pdev);
 extern const struct dev_pm_ops stmmac_pltfr_pm_ops;
 
+static inline void *get_stmmac_bsp_priv(struct device *dev)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+	struct stmmac_priv *priv = netdev_priv(ndev);
+
+	return priv->plat->bsp_priv;
+}
+
 #endif /* __STMMAC_PLATFORM_H__ */
-- 
2.9.3

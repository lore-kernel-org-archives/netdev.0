From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [PATCH] net: phy: micrel: support !CONFIG_HAVE_CLK
Date: Mon, 27 Apr 2015 13:00:50 +0200
Message-ID: <1430132450-4496-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <johan@kernel.org>,
	Niklas Cassel <niklass@axis.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since NULL is a valid clock, we shouldn't use
IS_ERR_OR_NULL.

Implemented as Russell King suggested in:

http://lkml.kernel.org/r/20150207172949.GE8656@n2100.arm.linux.org.uk

Signed-off-by: Niklas Cassel <niklass@axis.com>
---
 drivers/net/phy/micrel.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 1190fd8..d958d13 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -522,6 +522,7 @@ static int kszphy_probe(struct phy_device *phydev)
 	struct device_node *np = phydev->dev.of_node;
 	struct kszphy_priv *priv;
 	struct clk *clk;
+	unsigned long rate = 0;
 	int ret;
 
 	priv = devm_kzalloc(&phydev->dev, sizeof(*priv), GFP_KERNEL);
@@ -548,8 +549,10 @@ static int kszphy_probe(struct phy_device *phydev)
 	}
 
 	clk = devm_clk_get(&phydev->dev, "rmii-ref");
-	if (!IS_ERR(clk)) {
-		unsigned long rate = clk_get_rate(clk);
+	if (!IS_ERR(clk))
+		rate = clk_get_rate(clk);
+
+	if (rate) {
 		bool rmii_ref_clk_sel_25_mhz;
 
 		priv->rmii_ref_clk_sel = type->has_rmii_ref_clk_sel;
-- 
2.1.4

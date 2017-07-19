From: Philipp Zabel <p.zabel@pengutronix.de>
Subject: [PATCH 044/102] net: dsa: mt7530: explicitly request exclusive reset control
Date: Wed, 19 Jul 2017 17:25:48 +0200
Message-ID: <20170719152646.25903-45-p.zabel@pengutronix.de>
References: <20170719152646.25903-1-p.zabel@pengutronix.de>
Cc: Philipp Zabel <p.zabel@pengutronix.de>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170719152646.25903-1-p.zabel@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit a53e35db70d1 ("reset: Ensure drivers are explicit when requesting
reset lines") started to transition the reset control request API calls
to explicitly state whether the driver needs exclusive or shared reset
control behavior. Convert all drivers requesting exclusive resets to the
explicit API call so the temporary transition helpers can be removed.

No functional changes.

Cc: Andrew Lunn <andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Philipp Zabel <p.zabel@pengutronix.de>
---
 drivers/net/dsa/mt7530.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index 1e46418a3b74c..657d06b3c6c47 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -1044,7 +1044,8 @@ mt7530_probe(struct mdio_device *mdiodev)
 	if (priv->mcm) {
 		dev_info(&mdiodev->dev, "MT7530 adapts as multi-chip module\n");
 
-		priv->rstc = devm_reset_control_get(&mdiodev->dev, "mcm");
+		priv->rstc = devm_reset_control_get_exclusive(&mdiodev->dev,
+							      "mcm");
 		if (IS_ERR(priv->rstc)) {
 			dev_err(&mdiodev->dev, "Couldn't get our reset line\n");
 			return PTR_ERR(priv->rstc);
-- 
2.11.0

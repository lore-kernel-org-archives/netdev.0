From: Florian Vaussard <florian.vaussard@epfl.ch>
Subject: [PATCH 5/5] can: sja1000: of: add read/write routines for 8, 16 and 32-bit register access
Date: Thu, 30 Jan 2014 15:29:28 +0100
Message-ID: <1391092168-21246-6-git-send-email-florian.vaussard@epfl.ch>
References: <1391092168-21246-1-git-send-email-florian.vaussard@epfl.ch>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, florian.vaussard@epfl.ch,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, devicetree@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391092168-21246-1-git-send-email-florian.vaussard@epfl.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add routines for 8, 16 and 32-bit access like in sja1000_platform.c

Cc: Grant Likely <grant.likely@linaro.org>
Cc: Rob Herring <robh+dt@kernel.org>
Cc: Pawel Moll <pawel.moll@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Ian Campbell <ijc+devicetree@hellion.org.uk>
Cc: Kumar Gala <galak@codeaurora.org>
Cc: devicetree@vger.kernel.org
Signed-off-by: Florian Vaussard <florian.vaussard@epfl.ch>
---
 drivers/net/can/sja1000/sja1000_of_platform.c | 41 +++++++++++++++++++++++----
 1 file changed, 36 insertions(+), 5 deletions(-)

diff --git a/drivers/net/can/sja1000/sja1000_of_platform.c b/drivers/net/can/sja1000/sja1000_of_platform.c
index 8ebb4af..a9a0696 100644
--- a/drivers/net/can/sja1000/sja1000_of_platform.c
+++ b/drivers/net/can/sja1000/sja1000_of_platform.c
@@ -55,17 +55,39 @@ MODULE_LICENSE("GPL v2");
 
 #define SJA1000_OFP_CAN_CLOCK  (16000000 / 2)
 
-static u8 sja1000_ofp_read_reg(const struct sja1000_priv *priv, int reg)
+static u8 sja1000_ofp_read_reg8(const struct sja1000_priv *priv, int reg)
 {
 	return ioread8(priv->reg_base + reg);
 }
 
-static void sja1000_ofp_write_reg(const struct sja1000_priv *priv,
-				  int reg, u8 val)
+static void sja1000_ofp_write_reg8(const struct sja1000_priv *priv,
+				   int reg, u8 val)
 {
 	iowrite8(val, priv->reg_base + reg);
 }
 
+static u8 sja1000_ofp_read_reg16(const struct sja1000_priv *priv, int reg)
+{
+	return ioread8(priv->reg_base + reg * 2);
+}
+
+static void sja1000_ofp_write_reg16(const struct sja1000_priv *priv,
+				    int reg, u8 val)
+{
+	iowrite8(val, priv->reg_base + reg * 2);
+}
+
+static u8 sja1000_ofp_read_reg32(const struct sja1000_priv *priv, int reg)
+{
+	return ioread8(priv->reg_base + reg * 4);
+}
+
+static void sja1000_ofp_write_reg32(const struct sja1000_priv *priv,
+				    int reg, u8 val)
+{
+	iowrite8(val, priv->reg_base + reg * 4);
+}
+
 static int sja1000_ofp_remove(struct platform_device *ofdev)
 {
 	struct net_device *dev = platform_get_drvdata(ofdev);
@@ -121,8 +143,17 @@ static int sja1000_ofp_probe(struct platform_device *ofdev)
 
 	priv = netdev_priv(dev);
 
-	priv->read_reg = sja1000_ofp_read_reg;
-	priv->write_reg = sja1000_ofp_write_reg;
+	of_property_read_u32(np, "reg-io-width", &prop);
+	if (prop == 4) {
+		priv->read_reg = sja1000_ofp_read_reg32;
+		priv->write_reg = sja1000_ofp_write_reg32;
+	} else if (prop == 2) {
+		priv->read_reg = sja1000_ofp_read_reg16;
+		priv->write_reg = sja1000_ofp_write_reg16;
+	} else {
+		priv->read_reg = sja1000_ofp_read_reg8;
+		priv->write_reg = sja1000_ofp_write_reg8;
+	}
 
 	err = of_property_read_u32(np, "nxp,external-clock-frequency", &prop);
 	if (!err)
-- 
1.8.1.2

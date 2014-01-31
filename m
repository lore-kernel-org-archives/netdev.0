From: Florian Vaussard <florian.vaussard@epfl.ch>
Subject: [PATCH v3 5/5] can: sja1000: of: add reg-io-width property for 8, 16 and 32-bit register access
Date: Fri, 31 Jan 2014 14:34:37 +0100
Message-ID: <1391175277-19833-6-git-send-email-florian.vaussard@epfl.ch>
References: <1391175277-19833-1-git-send-email-florian.vaussard@epfl.ch>
Cc: Andreas Larsson <andreas@gaisler.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, sparclinux@vger.kernel.org,
	linux-kernel@vger.kernel.org, florian.vaussard@epfl.ch
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391175277-19833-1-git-send-email-florian.vaussard@epfl.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the 'reg-io-width' property for 8, 16 and 32-bit access, like
what is currently done with IORESOURCE_MEM_{8,16,32}BIT for non-OF
boot.

Signed-off-by: Florian Vaussard <florian.vaussard@epfl.ch>
---
 drivers/net/can/sja1000/sja1000_platform.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/can/sja1000/sja1000_platform.c
index 50dece8..25122bf 100644
--- a/drivers/net/can/sja1000/sja1000_platform.c
+++ b/drivers/net/can/sja1000/sja1000_platform.c
@@ -102,8 +102,20 @@ static void sp_populate_of(struct sja1000_priv *priv, struct device_node *of)
 	int err;
 	u32 prop;
 
-	priv->read_reg = sp_read_reg8;
-	priv->write_reg = sp_write_reg8;
+	err = of_property_read_u32(of, "reg-io-width", &prop);
+	if (err)
+		prop = 1;
+
+	if (prop == 4) {
+		priv->read_reg = sp_read_reg32;
+		priv->write_reg = sp_write_reg32;
+	} else if (prop == 2) {
+		priv->read_reg = sp_read_reg16;
+		priv->write_reg = sp_write_reg16;
+	} else {
+		priv->read_reg = sp_read_reg8;
+		priv->write_reg = sp_write_reg8;
+	}
 
 	err = of_property_read_u32(of, "nxp,external-clock-frequency", &prop);
 	if (!err)
-- 
1.8.1.2

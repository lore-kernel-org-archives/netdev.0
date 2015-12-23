From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 05/28] net: dsa: Pass the dsa device to the switch drivers
Date: Wed, 23 Dec 2015 13:56:19 +0100
Message-ID: <1450875402-20740-6-git-send-email-andrew@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48679 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757069AbbLWM5Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 07:57:24 -0500
In-Reply-To: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By passing a device structure to the switch devices, it allows them
to use devm_* methods for resource management.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/bcm_sf2.c   | 2 +-
 drivers/net/dsa/mv88e6060.c | 2 +-
 drivers/net/dsa/mv88e6123.c | 2 +-
 drivers/net/dsa/mv88e6131.c | 2 +-
 drivers/net/dsa/mv88e6171.c | 2 +-
 drivers/net/dsa/mv88e6352.c | 2 +-
 include/net/dsa.h           | 2 +-
 net/dsa/dsa.c               | 2 +-
 8 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 6f946fedbb77..6925b3c13895 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -926,7 +926,7 @@ static void bcm_sf2_identify_ports(struct bcm_sf2_priv *priv,
 	}
 }
 
-static int bcm_sf2_sw_setup(struct dsa_switch *ds)
+static int bcm_sf2_sw_setup(struct dsa_switch *ds, struct device *dev)
 {
 	const char *reg_names[BCM_SF2_REGS_NUM] = BCM_SF2_REGS_NAME;
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index 0527f485c3dc..34bc374882c7 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -172,7 +172,7 @@ static int mv88e6060_setup_port(struct dsa_switch *ds, int p)
 	return 0;
 }
 
-static int mv88e6060_setup(struct dsa_switch *ds)
+static int mv88e6060_setup(struct dsa_switch *ds, struct device *dev)
 {
 	int i;
 	int ret;
diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 69a6f79dcb10..fab428bb7545 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -68,7 +68,7 @@ static int mv88e6123_setup_global(struct dsa_switch *ds)
 	return 0;
 }
 
-static int mv88e6123_setup(struct dsa_switch *ds)
+static int mv88e6123_setup(struct dsa_switch *ds, struct device *dev)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index a92ca651c399..d82cf3d38455 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -86,7 +86,7 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 	return 0;
 }
 
-static int mv88e6131_setup(struct dsa_switch *ds)
+static int mv88e6131_setup(struct dsa_switch *ds, struct device *dev)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 6e18213b9c04..9635f14ec1fb 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -64,7 +64,7 @@ static int mv88e6171_setup_global(struct dsa_switch *ds)
 	return 0;
 }
 
-static int mv88e6171_setup(struct dsa_switch *ds)
+static int mv88e6171_setup(struct dsa_switch *ds, struct device *dev)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index cc6c54553418..c2c4153e3423 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -75,7 +75,7 @@ static int mv88e6352_setup_global(struct dsa_switch *ds)
 	return 0;
 }
 
-static int mv88e6352_setup(struct dsa_switch *ds)
+static int mv88e6352_setup(struct dsa_switch *ds, struct device *dev)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 26a0e86e611e..f5b4f1bcfdf3 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -213,7 +213,7 @@ struct dsa_switch_driver {
 	 * Probing and setup.
 	 */
 	char	*(*probe)(struct device *host_dev, int sw_addr);
-	int	(*setup)(struct dsa_switch *ds);
+	int	(*setup)(struct dsa_switch *ds, struct device *dev);
 	int	(*set_addr)(struct dsa_switch *ds, u8 *addr);
 	u32	(*get_phy_flags)(struct dsa_switch *ds, int port);
 
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 704502c22306..7170c93637c8 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -300,7 +300,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	/*
 	 * Do basic register setup.
 	 */
-	ret = drv->setup(ds);
+	ret = drv->setup(ds, parent);
 	if (ret < 0)
 		goto out;
 
-- 
2.6.3

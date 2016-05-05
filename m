From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 15/20] net: dsa: mv88e6xxx: factorize GLOBAL_MONITOR_CONTROL setup
Date: Thu,  5 May 2016 18:40:59 -0400
Message-ID: <1462488064-1841-16-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All switch drivers configure the GLOBAL_MONITOR_CONTROL register with
slightly changes.

Assume the setup of the upstream port, and configure it as the port to
which ingress and egress and ARP monitor frames are to be sent.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123.c | 14 --------------
 drivers/net/dsa/mv88e6131.c | 13 -------------
 drivers/net/dsa/mv88e6171.c | 15 ---------------
 drivers/net/dsa/mv88e6352.c | 14 --------------
 drivers/net/dsa/mv88e6xxx.c | 12 ++++++++++++
 5 files changed, 12 insertions(+), 56 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 077fe30..98eaee1 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -57,20 +57,6 @@ static const char *mv88e6123_drv_probe(struct device *dsa_dev,
 static int mv88e6123_setup_global(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	u32 upstream_port = dsa_upstream_port(ds);
-	int ret;
-	u32 reg;
-
-	/* Configure the upstream port, and configure the upstream
-	 * port as the port to which ingress and egress monitor frames
-	 * are to be sent.
-	 */
-	reg = upstream_port << GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
-		upstream_port << GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
-		upstream_port << GLOBAL_MONITOR_CONTROL_ARP_SHIFT;
-	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_MONITOR_CONTROL, reg);
-	if (ret)
-		return ret;
 
 	/* Disable remote management for now, and set the switch's
 	 * DSA device number.
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 4c0b1e9..c675070 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -77,20 +77,7 @@ static const char *mv88e6131_drv_probe(struct device *dsa_dev,
 static int mv88e6131_setup_global(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	u32 upstream_port = dsa_upstream_port(ds);
 	int ret;
-	u32 reg;
-
-	/* Disable ARP mirroring, and configure the upstream port as
-	 * the port to which ingress and egress monitor frames are to
-	 * be sent.
-	 */
-	reg = upstream_port << GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
-		upstream_port << GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
-		GLOBAL_MONITOR_CONTROL_ARP_DISABLED;
-	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_MONITOR_CONTROL, reg);
-	if (ret)
-		return ret;
 
 	/* Disable cascade port functionality unless this device
 	 * is used in a cascade configuration, and set the switch's
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index f7dbf78..4c14f9f 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -89,21 +89,6 @@ static const char *mv88e6171_drv_probe(struct device *dsa_dev,
 static int mv88e6171_setup_global(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	u32 upstream_port = dsa_upstream_port(ds);
-	int ret;
-	u32 reg;
-
-	/* Configure the upstream port, and configure the upstream
-	 * port as the port to which ingress and egress monitor frames
-	 * are to be sent.
-	 */
-	reg = upstream_port << GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
-		upstream_port << GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
-		upstream_port << GLOBAL_MONITOR_CONTROL_ARP_SHIFT |
-		upstream_port << GLOBAL_MONITOR_CONTROL_MIRROR_SHIFT;
-	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_MONITOR_CONTROL, reg);
-	if (ret)
-		return ret;
 
 	/* Disable remote management for now, and set the switch's
 	 * DSA device number.
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 54849f5..52547d0 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -140,20 +140,6 @@ static const char *mv88e6352_drv_probe(struct device *dsa_dev,
 static int mv88e6352_setup_global(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	u32 upstream_port = dsa_upstream_port(ds);
-	int ret;
-	u32 reg;
-
-	/* Configure the upstream port, and configure the upstream
-	 * port as the port to which ingress and egress monitor frames
-	 * are to be sent.
-	 */
-	reg = upstream_port << GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
-		upstream_port << GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
-		upstream_port << GLOBAL_MONITOR_CONTROL_ARP_SHIFT;
-	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_MONITOR_CONTROL, reg);
-	if (ret)
-		return ret;
 
 	/* Disable remote management for now, and set the switch's
 	 * DSA device number.
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index f7fca3e..de37f20 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2912,6 +2912,8 @@ int mv88e6xxx_setup_ports(struct dsa_switch *ds)
 
 static int _mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
 {
+	struct dsa_switch *ds = ps->ds;
+	u32 upstream_port = dsa_upstream_port(ds);
 	u16 reg;
 	int err;
 	int i;
@@ -2937,6 +2939,16 @@ static int _mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
 			return err;
 	}
 
+	/* Configure the upstream port, and configure it as the port to which
+	 * ingress and egress and ARP monitor frames are to be sent.
+	 */
+	reg = upstream_port << GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
+		upstream_port << GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
+		upstream_port << GLOBAL_MONITOR_CONTROL_ARP_SHIFT;
+	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_MONITOR_CONTROL, reg);
+	if (err)
+		return err;
+
 	/* Set the default address aging time to 5 minutes, and
 	 * enable address learn messages to be sent to all message
 	 * ports.
-- 
2.8.2

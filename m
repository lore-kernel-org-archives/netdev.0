From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 18/20] net: dsa: mv88e6xxx: add flags to info
Date: Wed, 27 Apr 2016 18:30:15 -0400
Message-ID: <1461796217-18893-19-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a flags bitmap to the mv88e6xxx_info structure to help describing
features supported or not by a switch model.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 56e3347..325caf8 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -338,6 +338,10 @@
 
 #define MV88E6XXX_N_FID		4096
 
+enum mv88e6xxx_flag {
+	MV88E6XXX_NUM_FLAGS,
+};
+
 enum mv88e6xxx_family {
 	MV88E6XXX_FAMILY_NONE,
 	MV88E6XXX_FAMILY_6065,	/* 6031 6035 6061 6065 */
@@ -356,6 +360,7 @@ struct mv88e6xxx_info {
 	const char *name;
 	unsigned int num_databases;
 	unsigned int num_ports;
+	unsigned long flags;
 };
 
 struct mv88e6xxx_atu_entry {
@@ -445,6 +450,12 @@ struct mv88e6xxx_hw_stat {
 	enum stat_type type;
 };
 
+static inline bool mv88e6xxx_has(struct mv88e6xxx_priv_state *ps,
+				 enum mv88e6xxx_flag flag)
+{
+	return !!(ps->info->flags & BIT(flag));
+}
+
 int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active);
 const char *mv88e6xxx_drv_probe(struct device *dsa_dev, struct device *host_dev,
 				int sw_addr, void **priv,
-- 
2.8.0

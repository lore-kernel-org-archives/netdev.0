From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 4/9] net: dsa: rename dsa_is_normal_port helper
Date: Thu, 26 Oct 2017 11:22:54 -0400
Message-ID: <20171026152259.3123-5-vivien.didelot@savoirfairelinux.com>
References: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch renames dsa_is_normal_port to dsa_is_user_port because "user"
is the correct term in the DSA terminology, not "normal".

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 2 +-
 include/net/dsa.h                | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 2d8cf66e8f74..09a66d4d9492 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1676,7 +1676,7 @@ static int mv88e6xxx_setup_port_mode(struct mv88e6xxx_chip *chip, int port)
 	if (dsa_is_dsa_port(chip->ds, port))
 		return mv88e6xxx_set_port_mode_dsa(chip, port);
 
-	if (dsa_is_normal_port(chip->ds, port))
+	if (dsa_is_user_port(chip->ds, port))
 		return mv88e6xxx_set_port_mode_normal(chip, port);
 
 	/* Setup CPU port mode depending on its supported tag format */
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 4ad432ad2d40..49701d958663 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -271,7 +271,7 @@ static inline bool dsa_is_dsa_port(struct dsa_switch *ds, int p)
 	return !!((ds->dsa_port_mask) & (1 << p));
 }
 
-static inline bool dsa_is_normal_port(struct dsa_switch *ds, int p)
+static inline bool dsa_is_user_port(struct dsa_switch *ds, int p)
 {
 	return !!(ds->enabled_port_mask & BIT(p));
 }
-- 
2.14.3

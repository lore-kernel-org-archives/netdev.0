From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 13/16] net: dsa: Centralise getting switch id
Date: Thu, 26 Mar 2015 18:36:40 -0700
Message-ID: <1427420203-27685-14-git-send-email-linux@roeck-us.net>
References: <1427420203-27685-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427420203-27685-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn <andrew@lunn.ch>

Get the switch id and save it away in the private mv88x6xxx structure
in a centralised piece of code, rather than each driver doing it itself.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Guenter Roeck <linux@roeck-us.net>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6352.c | 2 --
 drivers/net/dsa/mv88e6xxx.c | 2 ++
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 7285bd053363..41fe3a6a72d1 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -369,8 +369,6 @@ static int mv88e6352_setup(struct dsa_switch *ds)
 
 	mutex_init(&ps->eeprom_mutex);
 
-	ps->id = REG_READ(REG_PORT(0), 0x03) & 0xfff0;
-
 	ret = mv88e6352_switch_reset(ds);
 	if (ret < 0)
 		return ret;
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 038802229e32..13572cc24c6d 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1152,6 +1152,8 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 	mutex_init(&ps->stats_mutex);
 	mutex_init(&ps->phy_mutex);
 
+	ps->id = REG_READ(REG_PORT(0), 0x03) & 0xfff0;
+
 	ps->fid_mask = (1 << DSA_MAX_PORTS) - 1;
 
 	INIT_WORK(&ps->bridge_work, mv88e6xxx_bridge_work);
-- 
2.1.0

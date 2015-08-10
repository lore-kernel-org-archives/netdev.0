From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 3/8] net: dsa: mv88e6xxx: rename ATU MAC accessors
Date: Mon, 10 Aug 2015 09:09:48 -0400
Message-ID: <1439212193-7673-4-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1439212193-7673-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439212193-7673-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rename the __mv88e6xxx_{read,write}_addr functions to more explicit
_mv88e6xxx_atu_mac_{read,write} functions, which also respect the single
underscore convention used in the file (meaning SMI lock must be held).

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index d8ec3f6..6615e9f 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1182,8 +1182,8 @@ int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state)
 	return 0;
 }
 
-static int __mv88e6xxx_write_addr(struct dsa_switch *ds,
-				  const unsigned char *addr)
+static int _mv88e6xxx_atu_mac_write(struct dsa_switch *ds,
+				    const unsigned char *addr)
 {
 	int i, ret;
 
@@ -1198,7 +1198,7 @@ static int __mv88e6xxx_write_addr(struct dsa_switch *ds,
 	return 0;
 }
 
-static int __mv88e6xxx_read_addr(struct dsa_switch *ds, unsigned char *addr)
+static int _mv88e6xxx_atu_mac_read(struct dsa_switch *ds, unsigned char *addr)
 {
 	int i, ret;
 
@@ -1225,7 +1225,7 @@ static int __mv88e6xxx_port_fdb_cmd(struct dsa_switch *ds, int port,
 	if (ret < 0)
 		return ret;
 
-	ret = __mv88e6xxx_write_addr(ds, addr);
+	ret = _mv88e6xxx_atu_mac_write(ds, addr);
 	if (ret < 0)
 		return ret;
 
@@ -1280,7 +1280,7 @@ static int __mv88e6xxx_port_getnext(struct dsa_switch *ds, int port,
 	if (ret < 0)
 		return ret;
 
-	ret = __mv88e6xxx_write_addr(ds, addr);
+	ret = _mv88e6xxx_atu_mac_write(ds, addr);
 	if (ret < 0)
 		return ret;
 
@@ -1297,7 +1297,7 @@ static int __mv88e6xxx_port_getnext(struct dsa_switch *ds, int port,
 			return -ENOENT;
 	} while (!(((ret >> 4) & 0xff) & (1 << port)));
 
-	ret = __mv88e6xxx_read_addr(ds, addr);
+	ret = _mv88e6xxx_atu_mac_read(ds, addr);
 	if (ret < 0)
 		return ret;
 
@@ -1661,7 +1661,7 @@ static int mv88e6xxx_atu_show_db(struct seq_file *s, struct dsa_switch *ds,
 	unsigned char addr[6];
 	int ret, data, state;
 
-	ret = __mv88e6xxx_write_addr(ds, bcast);
+	ret = _mv88e6xxx_atu_mac_write(ds, bcast);
 	if (ret < 0)
 		return ret;
 
@@ -1676,7 +1676,7 @@ static int mv88e6xxx_atu_show_db(struct seq_file *s, struct dsa_switch *ds,
 		state = data & GLOBAL_ATU_DATA_STATE_MASK;
 		if (state == GLOBAL_ATU_DATA_STATE_UNUSED)
 			break;
-		ret = __mv88e6xxx_read_addr(ds, addr);
+		ret = _mv88e6xxx_atu_mac_read(ds, addr);
 		if (ret < 0)
 			return ret;
 		mv88e6xxx_atu_show_entry(s, dbnum, addr, data);
-- 
2.5.0

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 5/7] net: dsa: mv88e6xxx: flush all addresses when adding a VLAN
Date: Fri,  4 Sep 2015 14:34:14 -0400
Message-ID: <1441391656-22574-6-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1441391656-22574-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441391656-22574-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When choosing an address database for a new VLAN, flush every entries,
not only the non-static ones.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 38c8d4a..88d669c 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1630,7 +1630,8 @@ static int _mv88e6xxx_vlan_init(struct dsa_switch *ds, u16 vid,
 			return -ENOSPC;
 		}
 
-		err = _mv88e6xxx_flush_fid(ds, vlan.fid);
+		/* Clear all MAC addresses from the new database */
+		err = _mv88e6xxx_atu_flush(ds, vlan.fid, true);
 		if (err)
 			return err;
 
-- 
2.5.1

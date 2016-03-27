From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/7] net: dsa: mv88e6xxx: 6185 has only 256 FDBs
Date: Sat, 26 Mar 2016 21:59:38 -0400
Message-ID: <1459043983-12088-3-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1459043983-12088-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Patrick Uiterwijk <patrick@puiterwijk.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459043983-12088-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 6185 family has only 256 indexable address databases, while the
others (such as 6352) have 4095. Explicit and use these maximum values
in the _mv88e6xxx_fid_new function.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 1d9ae48..1d9b5dd 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1575,8 +1575,12 @@ static int _mv88e6xxx_fid_new(struct dsa_switch *ds, u16 *fid)
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	DECLARE_BITMAP(fid_bitmap, MV88E6XXX_N_FID);
 	struct mv88e6xxx_vtu_stu_entry vlan;
+	u16 max = 4095;
 	int i, err;
 
+	if (mv88e6xxx_6185_family(ds))
+		max = 256;
+
 	bitmap_zero(fid_bitmap, MV88E6XXX_N_FID);
 
 	/* Set every FID bit used by the (un)bridged ports */
@@ -1608,7 +1612,7 @@ static int _mv88e6xxx_fid_new(struct dsa_switch *ds, u16 *fid)
 	 * databases are not needed. Return the next positive available.
 	 */
 	*fid = find_next_zero_bit(fid_bitmap, MV88E6XXX_N_FID, 1);
-	if (unlikely(*fid == MV88E6XXX_N_FID))
+	if (unlikely(*fid > max))
 		return -ENOSPC;
 
 	/* Clear the database */
-- 
2.7.4

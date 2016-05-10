From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/2] net: dsa: mv88e6xxx: abstract VTU/STU data access
Date: Tue, 10 May 2016 15:44:28 -0400
Message-ID: <1462909469-4827-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Both VTU and STU operations use the same routine to access their
(common) data registers, with a different offset.

Add VTU and STU specific read and write functions to the data registers
to abstract the required offset.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 32 ++++++++++++++++++++++++++++----
 1 file changed, 28 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 1e5ca8e..92be27d 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1498,6 +1498,18 @@ static int _mv88e6xxx_vtu_stu_data_read(struct mv88e6xxx_priv_state *ps,
 	return 0;
 }
 
+static int mv88e6xxx_vtu_data_read(struct mv88e6xxx_priv_state *ps,
+				   struct mv88e6xxx_vtu_stu_entry *entry)
+{
+	return _mv88e6xxx_vtu_stu_data_read(ps, entry, 0);
+}
+
+static int mv88e6xxx_stu_data_read(struct mv88e6xxx_priv_state *ps,
+				   struct mv88e6xxx_vtu_stu_entry *entry)
+{
+	return _mv88e6xxx_vtu_stu_data_read(ps, entry, 2);
+}
+
 static int _mv88e6xxx_vtu_stu_data_write(struct mv88e6xxx_priv_state *ps,
 					 struct mv88e6xxx_vtu_stu_entry *entry,
 					 unsigned int nibble_offset)
@@ -1523,6 +1535,18 @@ static int _mv88e6xxx_vtu_stu_data_write(struct mv88e6xxx_priv_state *ps,
 	return 0;
 }
 
+static int mv88e6xxx_vtu_data_write(struct mv88e6xxx_priv_state *ps,
+				    struct mv88e6xxx_vtu_stu_entry *entry)
+{
+	return _mv88e6xxx_vtu_stu_data_write(ps, entry, 0);
+}
+
+static int mv88e6xxx_stu_data_write(struct mv88e6xxx_priv_state *ps,
+				    struct mv88e6xxx_vtu_stu_entry *entry)
+{
+	return _mv88e6xxx_vtu_stu_data_write(ps, entry, 2);
+}
+
 static int _mv88e6xxx_vtu_vid_write(struct mv88e6xxx_priv_state *ps, u16 vid)
 {
 	return _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_VTU_VID,
@@ -1551,7 +1575,7 @@ static int _mv88e6xxx_vtu_getnext(struct mv88e6xxx_priv_state *ps,
 	next.valid = !!(ret & GLOBAL_VTU_VID_VALID);
 
 	if (next.valid) {
-		ret = _mv88e6xxx_vtu_stu_data_read(ps, &next, 0);
+		ret = mv88e6xxx_vtu_data_read(ps, &next);
 		if (ret < 0)
 			return ret;
 
@@ -1658,7 +1682,7 @@ static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_priv_state *ps,
 		goto loadpurge;
 
 	/* Write port member tags */
-	ret = _mv88e6xxx_vtu_stu_data_write(ps, entry, 0);
+	ret = mv88e6xxx_vtu_data_write(ps, entry);
 	if (ret < 0)
 		return ret;
 
@@ -1724,7 +1748,7 @@ static int _mv88e6xxx_stu_getnext(struct mv88e6xxx_priv_state *ps, u8 sid,
 	next.valid = !!(ret & GLOBAL_VTU_VID_VALID);
 
 	if (next.valid) {
-		ret = _mv88e6xxx_vtu_stu_data_read(ps, &next, 2);
+		ret = mv88e6xxx_stu_data_read(ps, &next);
 		if (ret < 0)
 			return ret;
 	}
@@ -1747,7 +1771,7 @@ static int _mv88e6xxx_stu_loadpurge(struct mv88e6xxx_priv_state *ps,
 		goto loadpurge;
 
 	/* Write port states */
-	ret = _mv88e6xxx_vtu_stu_data_write(ps, entry, 2);
+	ret = mv88e6xxx_stu_data_write(ps, entry);
 	if (ret < 0)
 		return ret;
 
-- 
2.8.2

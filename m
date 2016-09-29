From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 06/10] net: dsa: mv88e6xxx: rename mv88e6xxx_vtu_stu_entry
Date: Thu, 29 Sep 2016 12:21:58 -0400
Message-ID: <20160929162202.10685-7-vivien.didelot@savoirfairelinux.com>
References: <20160929162202.10685-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160929162202.10685-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The STU (if the switch has one) is abstracted and accessed through the
VTU operations and data registers.

Thus rename the mv88e6xxx_vtu_stu_entry struct to mv88e6xxx_vtu_entry.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 46 +++++++++++++++++------------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  5 +---
 2 files changed, 24 insertions(+), 27 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 9056d9e..d805661 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1265,7 +1265,7 @@ static int _mv88e6xxx_vtu_stu_flush(struct mv88e6xxx_chip *chip)
 }
 
 static int _mv88e6xxx_vtu_stu_data_read(struct mv88e6xxx_chip *chip,
-					struct mv88e6xxx_vtu_stu_entry *entry,
+					struct mv88e6xxx_vtu_entry *entry,
 					unsigned int nibble_offset)
 {
 	u16 regs[3];
@@ -1290,19 +1290,19 @@ static int _mv88e6xxx_vtu_stu_data_read(struct mv88e6xxx_chip *chip,
 }
 
 static int mv88e6xxx_vtu_data_read(struct mv88e6xxx_chip *chip,
-				   struct mv88e6xxx_vtu_stu_entry *entry)
+				   struct mv88e6xxx_vtu_entry *entry)
 {
 	return _mv88e6xxx_vtu_stu_data_read(chip, entry, 0);
 }
 
 static int mv88e6xxx_stu_data_read(struct mv88e6xxx_chip *chip,
-				   struct mv88e6xxx_vtu_stu_entry *entry)
+				   struct mv88e6xxx_vtu_entry *entry)
 {
 	return _mv88e6xxx_vtu_stu_data_read(chip, entry, 2);
 }
 
 static int _mv88e6xxx_vtu_stu_data_write(struct mv88e6xxx_chip *chip,
-					 struct mv88e6xxx_vtu_stu_entry *entry,
+					 struct mv88e6xxx_vtu_entry *entry,
 					 unsigned int nibble_offset)
 {
 	u16 regs[3] = { 0 };
@@ -1327,13 +1327,13 @@ static int _mv88e6xxx_vtu_stu_data_write(struct mv88e6xxx_chip *chip,
 }
 
 static int mv88e6xxx_vtu_data_write(struct mv88e6xxx_chip *chip,
-				    struct mv88e6xxx_vtu_stu_entry *entry)
+				    struct mv88e6xxx_vtu_entry *entry)
 {
 	return _mv88e6xxx_vtu_stu_data_write(chip, entry, 0);
 }
 
 static int mv88e6xxx_stu_data_write(struct mv88e6xxx_chip *chip,
-				    struct mv88e6xxx_vtu_stu_entry *entry)
+				    struct mv88e6xxx_vtu_entry *entry)
 {
 	return _mv88e6xxx_vtu_stu_data_write(chip, entry, 2);
 }
@@ -1345,9 +1345,9 @@ static int _mv88e6xxx_vtu_vid_write(struct mv88e6xxx_chip *chip, u16 vid)
 }
 
 static int _mv88e6xxx_vtu_getnext(struct mv88e6xxx_chip *chip,
-				  struct mv88e6xxx_vtu_stu_entry *entry)
+				  struct mv88e6xxx_vtu_entry *entry)
 {
-	struct mv88e6xxx_vtu_stu_entry next = { 0 };
+	struct mv88e6xxx_vtu_entry next = { 0 };
 	u16 val;
 	int err;
 
@@ -1407,7 +1407,7 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 				    int (*cb)(struct switchdev_obj *obj))
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
-	struct mv88e6xxx_vtu_stu_entry next;
+	struct mv88e6xxx_vtu_entry next;
 	u16 pvid;
 	int err;
 
@@ -1458,7 +1458,7 @@ unlock:
 }
 
 static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
-				    struct mv88e6xxx_vtu_stu_entry *entry)
+				    struct mv88e6xxx_vtu_entry *entry)
 {
 	u16 op = GLOBAL_VTU_OP_VTU_LOAD_PURGE;
 	u16 reg = 0;
@@ -1507,9 +1507,9 @@ loadpurge:
 }
 
 static int _mv88e6xxx_stu_getnext(struct mv88e6xxx_chip *chip, u8 sid,
-				  struct mv88e6xxx_vtu_stu_entry *entry)
+				  struct mv88e6xxx_vtu_entry *entry)
 {
-	struct mv88e6xxx_vtu_stu_entry next = { 0 };
+	struct mv88e6xxx_vtu_entry next = { 0 };
 	u16 val;
 	int err;
 
@@ -1549,7 +1549,7 @@ static int _mv88e6xxx_stu_getnext(struct mv88e6xxx_chip *chip, u8 sid,
 }
 
 static int _mv88e6xxx_stu_loadpurge(struct mv88e6xxx_chip *chip,
-				    struct mv88e6xxx_vtu_stu_entry *entry)
+				    struct mv88e6xxx_vtu_entry *entry)
 {
 	u16 reg = 0;
 	int err;
@@ -1652,7 +1652,7 @@ static int _mv88e6xxx_port_fid_set(struct mv88e6xxx_chip *chip,
 static int _mv88e6xxx_fid_new(struct mv88e6xxx_chip *chip, u16 *fid)
 {
 	DECLARE_BITMAP(fid_bitmap, MV88E6XXX_N_FID);
-	struct mv88e6xxx_vtu_stu_entry vlan;
+	struct mv88e6xxx_vtu_entry vlan;
 	int i, err;
 
 	bitmap_zero(fid_bitmap, MV88E6XXX_N_FID);
@@ -1694,10 +1694,10 @@ static int _mv88e6xxx_fid_new(struct mv88e6xxx_chip *chip, u16 *fid)
 }
 
 static int _mv88e6xxx_vtu_new(struct mv88e6xxx_chip *chip, u16 vid,
-			      struct mv88e6xxx_vtu_stu_entry *entry)
+			      struct mv88e6xxx_vtu_entry *entry)
 {
 	struct dsa_switch *ds = chip->ds;
-	struct mv88e6xxx_vtu_stu_entry vlan = {
+	struct mv88e6xxx_vtu_entry vlan = {
 		.valid = true,
 		.vid = vid,
 	};
@@ -1715,7 +1715,7 @@ static int _mv88e6xxx_vtu_new(struct mv88e6xxx_chip *chip, u16 vid,
 
 	if (mv88e6xxx_6097_family(chip) || mv88e6xxx_6165_family(chip) ||
 	    mv88e6xxx_6351_family(chip) || mv88e6xxx_6352_family(chip)) {
-		struct mv88e6xxx_vtu_stu_entry vstp;
+		struct mv88e6xxx_vtu_entry vstp;
 
 		/* Adding a VTU entry requires a valid STU entry. As VSTP is not
 		 * implemented, only one STU entry is needed to cover all VTU
@@ -1742,7 +1742,7 @@ static int _mv88e6xxx_vtu_new(struct mv88e6xxx_chip *chip, u16 vid,
 }
 
 static int _mv88e6xxx_vtu_get(struct mv88e6xxx_chip *chip, u16 vid,
-			      struct mv88e6xxx_vtu_stu_entry *entry, bool creat)
+			      struct mv88e6xxx_vtu_entry *entry, bool creat)
 {
 	int err;
 
@@ -1774,7 +1774,7 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 					u16 vid_begin, u16 vid_end)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
-	struct mv88e6xxx_vtu_stu_entry vlan;
+	struct mv88e6xxx_vtu_entry vlan;
 	int i, err;
 
 	if (!vid_begin)
@@ -1899,7 +1899,7 @@ mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
 static int _mv88e6xxx_port_vlan_add(struct mv88e6xxx_chip *chip, int port,
 				    u16 vid, bool untagged)
 {
-	struct mv88e6xxx_vtu_stu_entry vlan;
+	struct mv88e6xxx_vtu_entry vlan;
 	int err;
 
 	err = _mv88e6xxx_vtu_get(chip, vid, &vlan, true);
@@ -1944,7 +1944,7 @@ static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_chip *chip,
 				    int port, u16 vid)
 {
 	struct dsa_switch *ds = chip->ds;
-	struct mv88e6xxx_vtu_stu_entry vlan;
+	struct mv88e6xxx_vtu_entry vlan;
 	int i, err;
 
 	err = _mv88e6xxx_vtu_get(chip, vid, &vlan, false);
@@ -2103,7 +2103,7 @@ static int mv88e6xxx_port_db_load_purge(struct mv88e6xxx_chip *chip, int port,
 					const unsigned char *addr, u16 vid,
 					u8 state)
 {
-	struct mv88e6xxx_vtu_stu_entry vlan;
+	struct mv88e6xxx_vtu_entry vlan;
 	struct mv88e6xxx_atu_entry entry;
 	int err;
 
@@ -2278,7 +2278,7 @@ static int mv88e6xxx_port_db_dump(struct mv88e6xxx_chip *chip, int port,
 				  struct switchdev_obj *obj,
 				  int (*cb)(struct switchdev_obj *obj))
 {
-	struct mv88e6xxx_vtu_stu_entry vlan = {
+	struct mv88e6xxx_vtu_entry vlan = {
 		.vid = GLOBAL_VTU_VID_MASK, /* all ones */
 	};
 	u16 fid;
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index cf639ed..ee7873a 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -640,12 +640,9 @@ struct mv88e6xxx_atu_entry {
 	u8	mac[ETH_ALEN];
 };
 
-struct mv88e6xxx_vtu_stu_entry {
-	/* VTU only */
+struct mv88e6xxx_vtu_entry {
 	u16	vid;
 	u16	fid;
-
-	/* VTU and STU */
 	u8	sid;
 	bool	valid;
 	u8	data[DSA_MAX_PORTS];
-- 
2.10.0

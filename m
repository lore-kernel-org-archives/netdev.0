From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 15/18] net: dsa: mv88e6xxx: make VTU helpers static
Date: Mon,  1 May 2017 14:05:24 -0400
Message-ID: <20170501180527.11756-16-vivien.didelot@savoirfairelinux.com>
References: <20170501180527.11756-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170501180527.11756-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that we have chip operations for VTU accesses, mark all helpers from
global1_vtu.c as static. Only the various implementations of the
GetNext, LoadPurge and Flush operations need to be exposed.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/global1.h     | 24 -----------------
 drivers/net/dsa/mv88e6xxx/global1_vtu.c | 48 ++++++++++++++++-----------------
 2 files changed, 24 insertions(+), 48 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 60dd7079c756..82e9812b8ba7 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -50,30 +50,6 @@ int mv88e6xxx_g1_atu_flush(struct mv88e6xxx_chip *chip, u16 fid, bool all);
 int mv88e6xxx_g1_atu_remove(struct mv88e6xxx_chip *chip, u16 fid, int port,
 			    bool all);
 
-int mv88e6xxx_g1_vtu_fid_read(struct mv88e6xxx_chip *chip,
-			      struct mv88e6xxx_vtu_entry *entry);
-int mv88e6xxx_g1_vtu_fid_write(struct mv88e6xxx_chip *chip,
-			       struct mv88e6xxx_vtu_entry *entry);
-int mv88e6xxx_g1_vtu_sid_read(struct mv88e6xxx_chip *chip,
-			      struct mv88e6xxx_vtu_entry *entry);
-int mv88e6xxx_g1_vtu_sid_write(struct mv88e6xxx_chip *chip,
-			       struct mv88e6xxx_vtu_entry *entry);
-int mv88e6xxx_g1_vtu_vid_read(struct mv88e6xxx_chip *chip,
-			      struct mv88e6xxx_vtu_entry *entry);
-int mv88e6xxx_g1_vtu_vid_write(struct mv88e6xxx_chip *chip,
-			       struct mv88e6xxx_vtu_entry *entry);
-int mv88e6185_g1_vtu_data_read(struct mv88e6xxx_chip *chip,
-			       struct mv88e6xxx_vtu_entry *entry);
-int mv88e6185_g1_vtu_data_write(struct mv88e6xxx_chip *chip,
-				struct mv88e6xxx_vtu_entry *entry);
-int mv88e6xxx_g1_vtu_op_wait(struct mv88e6xxx_chip *chip);
-int mv88e6xxx_g1_vtu_op(struct mv88e6xxx_chip *chip, u16 op);
-int mv88e6xxx_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
-			     struct mv88e6xxx_vtu_entry *entry);
-int mv88e6xxx_g1_vtu_stu_getnext(struct mv88e6xxx_chip *chip,
-				 struct mv88e6xxx_vtu_entry *vtu);
-int mv88e6xxx_g1_vtu_stu_get(struct mv88e6xxx_chip *chip,
-			     struct mv88e6xxx_vtu_entry *vtu);
 int mv88e6185_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
 			     struct mv88e6xxx_vtu_entry *entry);
 int mv88e6185_g1_vtu_loadpurge(struct mv88e6xxx_chip *chip,
diff --git a/drivers/net/dsa/mv88e6xxx/global1_vtu.c b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
index 73e08c5c3948..469056d0b421 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_vtu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
@@ -16,8 +16,8 @@
 
 /* Offset 0x02: VTU FID Register */
 
-int mv88e6xxx_g1_vtu_fid_read(struct mv88e6xxx_chip *chip,
-			      struct mv88e6xxx_vtu_entry *entry)
+static int mv88e6xxx_g1_vtu_fid_read(struct mv88e6xxx_chip *chip,
+				     struct mv88e6xxx_vtu_entry *entry)
 {
 	u16 val;
 	int err;
@@ -31,8 +31,8 @@ int mv88e6xxx_g1_vtu_fid_read(struct mv88e6xxx_chip *chip,
 	return 0;
 }
 
-int mv88e6xxx_g1_vtu_fid_write(struct mv88e6xxx_chip *chip,
-			       struct mv88e6xxx_vtu_entry *entry)
+static int mv88e6xxx_g1_vtu_fid_write(struct mv88e6xxx_chip *chip,
+				      struct mv88e6xxx_vtu_entry *entry)
 {
 	u16 val = entry->fid & GLOBAL_VTU_FID_MASK;
 
@@ -41,8 +41,8 @@ int mv88e6xxx_g1_vtu_fid_write(struct mv88e6xxx_chip *chip,
 
 /* Offset 0x03: VTU SID Register */
 
-int mv88e6xxx_g1_vtu_sid_read(struct mv88e6xxx_chip *chip,
-			      struct mv88e6xxx_vtu_entry *entry)
+static int mv88e6xxx_g1_vtu_sid_read(struct mv88e6xxx_chip *chip,
+				     struct mv88e6xxx_vtu_entry *entry)
 {
 	u16 val;
 	int err;
@@ -56,8 +56,8 @@ int mv88e6xxx_g1_vtu_sid_read(struct mv88e6xxx_chip *chip,
 	return 0;
 }
 
-int mv88e6xxx_g1_vtu_sid_write(struct mv88e6xxx_chip *chip,
-			       struct mv88e6xxx_vtu_entry *entry)
+static int mv88e6xxx_g1_vtu_sid_write(struct mv88e6xxx_chip *chip,
+				      struct mv88e6xxx_vtu_entry *entry)
 {
 	u16 val = entry->sid & GLOBAL_VTU_SID_MASK;
 
@@ -66,12 +66,12 @@ int mv88e6xxx_g1_vtu_sid_write(struct mv88e6xxx_chip *chip,
 
 /* Offset 0x05: VTU Operation Register */
 
-int mv88e6xxx_g1_vtu_op_wait(struct mv88e6xxx_chip *chip)
+static int mv88e6xxx_g1_vtu_op_wait(struct mv88e6xxx_chip *chip)
 {
 	return mv88e6xxx_g1_wait(chip, GLOBAL_VTU_OP, GLOBAL_VTU_OP_BUSY);
 }
 
-int mv88e6xxx_g1_vtu_op(struct mv88e6xxx_chip *chip, u16 op)
+static int mv88e6xxx_g1_vtu_op(struct mv88e6xxx_chip *chip, u16 op)
 {
 	int err;
 
@@ -84,8 +84,8 @@ int mv88e6xxx_g1_vtu_op(struct mv88e6xxx_chip *chip, u16 op)
 
 /* Offset 0x06: VTU VID Register */
 
-int mv88e6xxx_g1_vtu_vid_read(struct mv88e6xxx_chip *chip,
-			      struct mv88e6xxx_vtu_entry *entry)
+static int mv88e6xxx_g1_vtu_vid_read(struct mv88e6xxx_chip *chip,
+				     struct mv88e6xxx_vtu_entry *entry)
 {
 	u16 val;
 	int err;
@@ -100,8 +100,8 @@ int mv88e6xxx_g1_vtu_vid_read(struct mv88e6xxx_chip *chip,
 	return 0;
 }
 
-int mv88e6xxx_g1_vtu_vid_write(struct mv88e6xxx_chip *chip,
-			       struct mv88e6xxx_vtu_entry *entry)
+static int mv88e6xxx_g1_vtu_vid_write(struct mv88e6xxx_chip *chip,
+				      struct mv88e6xxx_vtu_entry *entry)
 {
 	u16 val = entry->vid & 0xfff;
 
@@ -116,8 +116,8 @@ int mv88e6xxx_g1_vtu_vid_write(struct mv88e6xxx_chip *chip,
  * Offset 0x09: VTU/STU Data Register 3
  */
 
-int mv88e6185_g1_vtu_data_read(struct mv88e6xxx_chip *chip,
-			       struct mv88e6xxx_vtu_entry *entry)
+static int mv88e6185_g1_vtu_data_read(struct mv88e6xxx_chip *chip,
+				      struct mv88e6xxx_vtu_entry *entry)
 {
 	u16 regs[3];
 	int i;
@@ -144,8 +144,8 @@ int mv88e6185_g1_vtu_data_read(struct mv88e6xxx_chip *chip,
 	return 0;
 }
 
-int mv88e6185_g1_vtu_data_write(struct mv88e6xxx_chip *chip,
-				struct mv88e6xxx_vtu_entry *entry)
+static int mv88e6185_g1_vtu_data_write(struct mv88e6xxx_chip *chip,
+				       struct mv88e6xxx_vtu_entry *entry)
 {
 	u16 regs[3] = { 0 };
 	int i;
@@ -174,8 +174,8 @@ int mv88e6185_g1_vtu_data_write(struct mv88e6xxx_chip *chip,
 
 /* VLAN Translation Unit Operations */
 
-int mv88e6xxx_g1_vtu_stu_getnext(struct mv88e6xxx_chip *chip,
-				 struct mv88e6xxx_vtu_entry *entry)
+static int mv88e6xxx_g1_vtu_stu_getnext(struct mv88e6xxx_chip *chip,
+					struct mv88e6xxx_vtu_entry *entry)
 {
 	int err;
 
@@ -194,8 +194,8 @@ int mv88e6xxx_g1_vtu_stu_getnext(struct mv88e6xxx_chip *chip,
 	return mv88e6xxx_g1_vtu_vid_read(chip, entry);
 }
 
-int mv88e6xxx_g1_vtu_stu_get(struct mv88e6xxx_chip *chip,
-			     struct mv88e6xxx_vtu_entry *vtu)
+static int mv88e6xxx_g1_vtu_stu_get(struct mv88e6xxx_chip *chip,
+				    struct mv88e6xxx_vtu_entry *vtu)
 {
 	struct mv88e6xxx_vtu_entry stu;
 	int err;
@@ -216,8 +216,8 @@ int mv88e6xxx_g1_vtu_stu_get(struct mv88e6xxx_chip *chip,
 	return 0;
 }
 
-int mv88e6xxx_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
-			     struct mv88e6xxx_vtu_entry *entry)
+static int mv88e6xxx_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
+				    struct mv88e6xxx_vtu_entry *entry)
 {
 	int err;
 
-- 
2.12.2

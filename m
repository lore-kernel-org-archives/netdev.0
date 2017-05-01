From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 10/18] net: dsa: mv88e6xxx: move STU GetNext operation
Date: Mon,  1 May 2017 14:05:19 -0400
Message-ID: <20170501180527.11756-11-vivien.didelot@savoirfairelinux.com>
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

Extract the generic portion of code to issue an STU GetNext operation,
which will be used in other implementations.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c        | 14 +-------------
 drivers/net/dsa/mv88e6xxx/global1.h     |  2 ++
 drivers/net/dsa/mv88e6xxx/global1_vtu.c | 20 ++++++++++++++++++++
 3 files changed, 23 insertions(+), 13 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index b163e40bf42e..5441b05f519b 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1422,19 +1422,7 @@ static int _mv88e6xxx_stu_getnext(struct mv88e6xxx_chip *chip, u8 sid,
 	if (err)
 		return err;
 
-	err = mv88e6xxx_g1_vtu_sid_write(chip, &next);
-	if (err)
-		return err;
-
-	err = mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_STU_GET_NEXT);
-	if (err)
-		return err;
-
-	err = mv88e6xxx_g1_vtu_sid_read(chip, &next);
-	if (err)
-		return err;
-
-	err = mv88e6xxx_g1_vtu_vid_read(chip, &next);
+	err = mv88e6xxx_g1_vtu_stu_getnext(chip, &next);
 	if (err)
 		return err;
 
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 9644ca649838..5d276cc4262b 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -70,6 +70,8 @@ int mv88e6xxx_g1_vtu_op_wait(struct mv88e6xxx_chip *chip);
 int mv88e6xxx_g1_vtu_op(struct mv88e6xxx_chip *chip, u16 op);
 int mv88e6xxx_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
 			     struct mv88e6xxx_vtu_entry *entry);
+int mv88e6xxx_g1_vtu_stu_getnext(struct mv88e6xxx_chip *chip,
+				 struct mv88e6xxx_vtu_entry *vtu);
 int mv88e6xxx_g1_vtu_flush(struct mv88e6xxx_chip *chip);
 
 #endif /* _MV88E6XXX_GLOBAL1_H */
diff --git a/drivers/net/dsa/mv88e6xxx/global1_vtu.c b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
index 060c4a5a802d..cf572ba76195 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_vtu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
@@ -174,6 +174,26 @@ int mv88e6185_g1_vtu_data_write(struct mv88e6xxx_chip *chip,
 
 /* VLAN Translation Unit Operations */
 
+int mv88e6xxx_g1_vtu_stu_getnext(struct mv88e6xxx_chip *chip,
+				 struct mv88e6xxx_vtu_entry *entry)
+{
+	int err;
+
+	err = mv88e6xxx_g1_vtu_sid_write(chip, entry);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_STU_GET_NEXT);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g1_vtu_sid_read(chip, entry);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g1_vtu_vid_read(chip, entry);
+}
+
 int mv88e6xxx_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
 			     struct mv88e6xxx_vtu_entry *entry)
 {
-- 
2.12.2

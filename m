From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 17/18] net: dsa: mv88e6xxx: support the VTU Page bit
Date: Mon,  1 May 2017 14:05:26 -0400
Message-ID: <20170501180527.11756-18-vivien.didelot@savoirfairelinux.com>
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

Newer chips such as the 88E6390 have a VTU Page bit in the VTU VID
register to specify a 13th bit for the VID. This can be used to support
8K VLANs.

When dumping the whole VTU, all VID bits must be set to one, including
this VTU Page bit. Add support for VID greater than 4095.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/global1_vtu.c | 7 +++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h   | 1 +
 2 files changed, 8 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/global1_vtu.c b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
index 469056d0b421..8e77974fb2f8 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_vtu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
@@ -95,6 +95,10 @@ static int mv88e6xxx_g1_vtu_vid_read(struct mv88e6xxx_chip *chip,
 		return err;
 
 	entry->vid = val & 0xfff;
+
+	if (val & GLOBAL_VTU_VID_PAGE)
+		entry->vid |= 0x1000;
+
 	entry->valid = !!(val & GLOBAL_VTU_VID_VALID);
 
 	return 0;
@@ -105,6 +109,9 @@ static int mv88e6xxx_g1_vtu_vid_write(struct mv88e6xxx_chip *chip,
 {
 	u16 val = entry->vid & 0xfff;
 
+	if (entry->vid & 0x1000)
+		val |= GLOBAL_VTU_VID_PAGE;
+
 	if (entry->valid)
 		val |= GLOBAL_VTU_VID_VALID;
 
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index a0d57b10acfe..77236cd72df2 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -249,6 +249,7 @@
 #define GLOBAL_VTU_OP_STU_GET_NEXT	((0x06 << 12) | GLOBAL_VTU_OP_BUSY)
 #define GLOBAL_VTU_VID		0x06
 #define GLOBAL_VTU_VID_MASK	0xfff
+#define GLOBAL_VTU_VID_PAGE	BIT(13)
 #define GLOBAL_VTU_VID_VALID	BIT(12)
 #define GLOBAL_VTU_DATA_0_3	0x07
 #define GLOBAL_VTU_DATA_4_7	0x08
-- 
2.12.2

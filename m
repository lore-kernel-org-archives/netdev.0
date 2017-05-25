From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v3 net-next 3/5] net: dsa: mv88e6xxx: Remove SERDES flag
Date: Fri, 26 May 2017 01:03:22 +0200
Message-ID: <1495753404-29943-4-git-send-email-andrew@lunn.ch>
References: <1495753404-29943-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45090 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1165913AbdEYXFJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 May 2017 19:05:09 -0400
In-Reply-To: <1495753404-29943-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we use an op for SERDES operations, we don't need a flag for
it. Remove it.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 23 ++---------------------
 drivers/net/dsa/mv88e6xxx/phy.c       |  3 ---
 2 files changed, 2 insertions(+), 24 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index fb996491b111..9087cb009cc3 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -508,14 +508,6 @@ enum mv88e6xxx_cap {
 	MV88E6XXX_CAP_SMI_CMD,		/* (0x00) SMI Command */
 	MV88E6XXX_CAP_SMI_DATA,		/* (0x01) SMI Data */
 
-	/* PHY Registers.
-	 */
-	MV88E6XXX_CAP_PHY_PAGE,		/* (0x16) Page Register */
-
-	/* Fiber/SERDES Registers (SMI address F).
-	 */
-	MV88E6XXX_CAP_SERDES,
-
 	/* Switch Global (1) Registers.
 	 */
 	MV88E6XXX_CAP_G1_ATU_FID,	/* (0x01) ATU FID Register */
@@ -550,10 +542,6 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_SMI_CMD		BIT_ULL(MV88E6XXX_CAP_SMI_CMD)
 #define MV88E6XXX_FLAG_SMI_DATA		BIT_ULL(MV88E6XXX_CAP_SMI_DATA)
 
-#define MV88E6XXX_FLAG_PHY_PAGE		BIT_ULL(MV88E6XXX_CAP_PHY_PAGE)
-
-#define MV88E6XXX_FLAG_SERDES		BIT_ULL(MV88E6XXX_CAP_SERDES)
-
 #define MV88E6XXX_FLAG_G1_VTU_FID	BIT_ULL(MV88E6XXX_CAP_G1_VTU_FID)
 
 #define MV88E6XXX_FLAG_GLOBAL2		BIT_ULL(MV88E6XXX_CAP_GLOBAL2)
@@ -574,11 +562,6 @@ enum mv88e6xxx_cap {
 	(MV88E6XXX_FLAG_SMI_CMD |	\
 	 MV88E6XXX_FLAG_SMI_DATA)
 
-/* Fiber/SERDES Registers at SMI address F, page 1 */
-#define MV88E6XXX_FLAGS_SERDES		\
-	(MV88E6XXX_FLAG_PHY_PAGE |	\
-	 MV88E6XXX_FLAG_SERDES)
-
 #define MV88E6XXX_FLAGS_FAMILY_6095	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
@@ -626,8 +609,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAGS_IRL |		\
-	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
-	 MV88E6XXX_FLAGS_SERDES)
+	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
 	(MV88E6XXX_FLAG_G1_VTU_FID |	\
@@ -648,8 +630,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAGS_IRL |		\
-	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
-	 MV88E6XXX_FLAGS_SERDES)
+	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6390	\
 	(MV88E6XXX_FLAG_EEE |		\
diff --git a/drivers/net/dsa/mv88e6xxx/phy.c b/drivers/net/dsa/mv88e6xxx/phy.c
index 0e6c72b93c8f..0d3e8aaedf50 100644
--- a/drivers/net/dsa/mv88e6xxx/phy.c
+++ b/drivers/net/dsa/mv88e6xxx/phy.c
@@ -62,9 +62,6 @@ int mv88e6xxx_phy_write(struct mv88e6xxx_chip *chip, int phy, int reg, u16 val)
 
 static int mv88e6xxx_phy_page_get(struct mv88e6xxx_chip *chip, int phy, u8 page)
 {
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_PHY_PAGE))
-		return -EOPNOTSUPP;
-
 	return mv88e6xxx_phy_write(chip, phy, PHY_PAGE, page);
 }
 
-- 
2.11.0

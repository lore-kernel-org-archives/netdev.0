From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH] bgmac: return error on failed PHY write
Date: Wed, 13 Feb 2013 10:14:51 +0100
Message-ID: <1360746891-15124-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:36810 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843Ab3BMJPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 04:15:24 -0500
Received: by mail-ee0-f50.google.com with SMTP id e51so512018eek.37
        for <netdev@vger.kernel.org>; Wed, 13 Feb 2013 01:15:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some callers may want to know if PHY write succeed. Also make PHY
functions static, they are not exported anywhere.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c |   10 +++++++---
 drivers/net/ethernet/broadcom/bgmac.h |    3 ---
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index 8cf5e39..d206133 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -535,7 +535,7 @@ static void bgmac_dma_init(struct bgmac *bgmac)
  * PHY ops
  **************************************************/
=20
-u16 bgmac_phy_read(struct bgmac *bgmac, u8 phyaddr, u8 reg)
+static u16 bgmac_phy_read(struct bgmac *bgmac, u8 phyaddr, u8 reg)
 {
 	struct bcma_device *core;
 	u16 phy_access_addr;
@@ -584,7 +584,7 @@ u16 bgmac_phy_read(struct bgmac *bgmac, u8 phyaddr,=
 u8 reg)
 }
=20
 /* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphywr */
-void bgmac_phy_write(struct bgmac *bgmac, u8 phyaddr, u8 reg, u16 valu=
e)
+static int bgmac_phy_write(struct bgmac *bgmac, u8 phyaddr, u8 reg, u1=
6 value)
 {
 	struct bcma_device *core;
 	u16 phy_access_addr;
@@ -617,9 +617,13 @@ void bgmac_phy_write(struct bgmac *bgmac, u8 phyad=
dr, u8 reg, u16 value)
 	tmp |=3D value;
 	bcma_write32(core, phy_access_addr, tmp);
=20
-	if (!bgmac_wait_value(core, phy_access_addr, BGMAC_PA_START, 0, 1000)=
)
+	if (!bgmac_wait_value(core, phy_access_addr, BGMAC_PA_START, 0, 1000)=
) {
 		bgmac_err(bgmac, "Writing to PHY %d register 0x%X failed\n",
 			  phyaddr, reg);
+		return -ETIMEDOUT;
+	}
+
+	return 0;
 }
=20
 /* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphyforce */
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethern=
et/broadcom/bgmac.h
index 3dd6f6f..4ede614 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -450,7 +450,4 @@ static inline void bgmac_set(struct bgmac *bgmac, u=
16 offset, u32 set)
 	bgmac_maskset(bgmac, offset, ~0, set);
 }
=20
-u16 bgmac_phy_read(struct bgmac *bgmac, u8 phyaddr, u8 reg);
-void bgmac_phy_write(struct bgmac *bgmac, u8 phyaddr, u8 reg, u16 valu=
e);
-
 #endif /* _BGMAC_H */
--=20
1.7.10.4

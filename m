From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH net v4] r8169: Remove duplicate of RTL_FEATURE_WOL
Date: Wed, 10 Feb 2016 06:22:02 +0200
Message-ID: <1455078122-2151-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-227-192.residential.rdsnet.ro ([5.14.227.192]:57622 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932330AbcBJEWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 23:22:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch remove multiple invocation of RTL_FEATURE_WOL.

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 17d5571..1f75478 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -8289,18 +8289,20 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	case RTL_GIGA_MAC_VER_49:
 	case RTL_GIGA_MAC_VER_50:
 	case RTL_GIGA_MAC_VER_51:
-		if (rtl_eri_read(tp, 0xdc, ERIAR_EXGMAC) & MagicPacket_v2)
-			tp->features |= RTL_FEATURE_WOL;
-		if ((RTL_R8(Config3) & LinkUp) != 0)
-			tp->features |= RTL_FEATURE_WOL;
+		if (rtl_eri_read(tp, 0xdc, ERIAR_EXGMAC) & MagicPacket_v2) {
+			if ((RTL_R8(Config5) & (UWF | BWF | MWF)) != 0) {
+				if ((RTL_R8(Config3) & LinkUp) != 0)
+					tp->features |= RTL_FEATURE_WOL;
+			}
+		}
 		break;
 	default:
-		if ((RTL_R8(Config3) & (LinkUp | MagicPacket)) != 0)
-			tp->features |= RTL_FEATURE_WOL;
+		if ((RTL_R8(Config3) & (LinkUp | MagicPacket)) != 0) {
+			if ((RTL_R8(Config5) & (UWF | BWF | MWF)) != 0)
+				tp->features |= RTL_FEATURE_WOL;
+		}
 		break;
 	}
-	if ((RTL_R8(Config5) & (UWF | BWF | MWF)) != 0)
-		tp->features |= RTL_FEATURE_WOL;
 	tp->features |= rtl_try_msi(tp, cfg);
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
-- 
2.5.0

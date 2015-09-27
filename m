From: Yoshinori Sato <ysato@users.sourceforge.jp>
Subject: [PATCH 1/2] ne: Add h8300 support.
Date: Sun, 27 Sep 2015 23:19:15 +0900
Message-ID: <1443363556-29937-1-git-send-email-ysato@users.sourceforge.jp>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.asahi-net.or.jp ([202.224.39.198]:58364 "EHLO
	mail2.asahi-net.or.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755765AbbI0OT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Sep 2015 10:19:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yoshinori Sato <ysato@users.sourceforge.jp>
---
 drivers/net/ethernet/8390/Kconfig | 2 +-
 drivers/net/ethernet/8390/ne.c    | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/8390/Kconfig b/drivers/net/ethernet/8390/Kconfig
index edf7225..44d7167 100644
--- a/drivers/net/ethernet/8390/Kconfig
+++ b/drivers/net/ethernet/8390/Kconfig
@@ -88,7 +88,7 @@ config MCF8390
 config NE2000
 	tristate "NE2000/NE1000 support"
 	depends on (ISA || (Q40 && m) || M32R || MACH_TX49XX || \
-		    ATARI_ETHERNEC)
+		    ATARI_ETHERNEC || H8300)
 	select CRC32
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y here.
diff --git a/drivers/net/ethernet/8390/ne.c b/drivers/net/ethernet/8390/ne.c
index c063b41..576917c 100644
--- a/drivers/net/ethernet/8390/ne.c
+++ b/drivers/net/ethernet/8390/ne.c
@@ -422,7 +422,8 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 		stop_page  = NE1SM_STOP_PG;
 	}
 
-#if  defined(CONFIG_PLAT_MAPPI) || defined(CONFIG_PLAT_OAKS32R)
+#if  defined(CONFIG_PLAT_MAPPI) || defined(CONFIG_PLAT_OAKS32R) || \
+	defined(CONFIG_H8300_KANEBEBE) || defined(CONFIG_H8300_AE3069)
 	neX000 = ((SA_prom[14] == 0x57  &&  SA_prom[15] == 0x57)
 		|| (SA_prom[14] == 0x42 && SA_prom[15] == 0x42));
 #else
-- 
2.1.4

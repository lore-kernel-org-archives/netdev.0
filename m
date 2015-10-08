From: Yoshinori Sato <ysato@users.sourceforge.jp>
Subject: [PATCH v3 1/2] ne: Add h8300 support.
Date: Thu,  8 Oct 2015 17:28:40 +0900
Message-ID: <1444292921-18598-1-git-send-email-ysato@users.sourceforge.jp>
References: <1443765891-32589-1-git-send-email-ysato@users.sourceforge.jp>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.asahi-net.or.jp ([202.224.39.198]:60833 "EHLO
	mail2.asahi-net.or.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181AbbJHI3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 04:29:00 -0400
In-Reply-To: <1443765891-32589-1-git-send-email-ysato@users.sourceforge.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes v3
none
Changes v2
Use CONFIG_H8300

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
index c063b41..90bf71b 100644
--- a/drivers/net/ethernet/8390/ne.c
+++ b/drivers/net/ethernet/8390/ne.c
@@ -422,7 +422,8 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 		stop_page  = NE1SM_STOP_PG;
 	}
 
-#if  defined(CONFIG_PLAT_MAPPI) || defined(CONFIG_PLAT_OAKS32R)
+#if  defined(CONFIG_PLAT_MAPPI) || defined(CONFIG_PLAT_OAKS32R) || \
+	defined(CONFIG_H8300)
 	neX000 = ((SA_prom[14] == 0x57  &&  SA_prom[15] == 0x57)
 		|| (SA_prom[14] == 0x42 && SA_prom[15] == 0x42));
 #else
-- 
2.1.4

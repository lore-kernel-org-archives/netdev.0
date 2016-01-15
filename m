From: Yoshinori Sato <ysato@users.sourceforge.jp>
Subject: [PATCH 2/2] ne: Add h8300 support.
Date: Sat, 16 Jan 2016 01:19:46 +0900
Message-ID: <1452874786-21202-2-git-send-email-ysato@users.sourceforge.jp>
References: <1452874786-21202-1-git-send-email-ysato@users.sourceforge.jp>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452874786-21202-1-git-send-email-ysato@users.sourceforge.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add H8/300 platform support.

Signed-off-by: Yoshinori Sato <ysato@users.sourceforge.jp>
---
 drivers/net/ethernet/8390/Kconfig | 2 +-
 drivers/net/ethernet/8390/ne.c    | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/8390/Kconfig b/drivers/net/ethernet/8390/Kconfig
index 29c3075..7530bd9 100644
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
index a9dde5b..e0ed765 100644
--- a/drivers/net/ethernet/8390/ne.c
+++ b/drivers/net/ethernet/8390/ne.c
@@ -427,7 +427,8 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 		stop_page  = NE1SM_STOP_PG;
 	}
 
-#if  defined(CONFIG_PLAT_MAPPI) || defined(CONFIG_PLAT_OAKS32R)
+#if  defined(CONFIG_PLAT_MAPPI) || defined(CONFIG_PLAT_OAKS32R) || \
+	defined(CONFIG_H8300)
 	neX000 = ((SA_prom[14] == 0x57  &&  SA_prom[15] == 0x57)
 		|| (SA_prom[14] == 0x42 && SA_prom[15] == 0x42));
 #else
-- 
2.6.1

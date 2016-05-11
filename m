From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: mvneta: bm: fix dependencies again
Date: Wed, 11 May 2016 22:13:23 +0200
Message-ID: <1462997636-1049487-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Marcin Wojtas <mw@semihalf.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I tried to fix this before, but my previous fix was incomplete
and we can still get the same link error in randconfig builds
because of the way that Kconfig treats the

	default y if MVNETA=y && MVNETA_BM_ENABLE

line that does not actually trigger when MVNETA_BM_ENABLE=m,
unlike I intended.
Changing the line to use MVNETA_BM_ENABLE!=n however has
the desired effect and hopefully makes all configurations
work as expected.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 019ded3aa7c9 ("net: mvneta: bm: clarify dependencies")
---
 drivers/net/ethernet/marvell/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index b5c6d42daa12..2664827ddecd 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -68,7 +68,7 @@ config MVNETA
 
 config MVNETA_BM
 	tristate
-	default y if MVNETA=y && MVNETA_BM_ENABLE
+	default y if MVNETA=y && MVNETA_BM_ENABLE!=n
 	default MVNETA_BM_ENABLE
 	select HWBM
 	help
-- 
2.7.0

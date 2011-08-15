From: Vladimir Zapolskiy <vz@mleia.com>
Subject: [PATCH] dm9000: control debug level of the driver
Date: Mon, 15 Aug 2011 19:38:34 +0300
Message-ID: <1313426314-6422-1-git-send-email-vz@mleia.com>
Cc: netdev@vger.kernel.org, Vladimir Zapolskiy <vz@mleia.com>,
	Ben Dooks <ben-linux@fluff.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from li271-223.members.linode.com ([178.79.152.223]:59364 "EHLO
	mail.mleia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750735Ab1HOQqZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Aug 2011 12:46:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change allows to get driver specific debug messages output
setting a default value for db->debug_level. As far as the maximum
level of verbosity is too high, it is demoted by default.

Signed-off-by: Vladimir Zapolskiy <vz@mleia.com>
Cc: Ben Dooks <ben-linux@fluff.org>
---
 drivers/net/Kconfig  |    2 +-
 drivers/net/dm9000.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 8d0314d..20e7936 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -988,7 +988,7 @@ config DM9000
 config DM9000_DEBUGLEVEL
 	int "DM9000 maximum debug level"
 	depends on DM9000
-	default 4
+	default 0
 	help
 	  The maximum level of debugging code compiled into the DM9000
 	  driver.
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 8ef31dc..b8509a8 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -138,8 +138,7 @@ typedef struct board_info {
 /* debug code */
 
 #define dm9000_dbg(db, lev, msg...) do {		\
-	if ((lev) < CONFIG_DM9000_DEBUGLEVEL &&		\
-	    (lev) < db->debug_level) {			\
+	if ((lev) < db->debug_level) {			\
 		dev_dbg(db->dev, msg);			\
 	}						\
 } while (0)
@@ -1381,6 +1380,7 @@ dm9000_probe(struct platform_device *pdev)
 
 	db->dev = &pdev->dev;
 	db->ndev = ndev;
+	db->debug_level = CONFIG_DM9000_DEBUGLEVEL;
 
 	spin_lock_init(&db->lock);
 	mutex_init(&db->addr_lock);
-- 
1.7.5.1


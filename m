From: Vladimir Zapolskiy <vz@mleia.com>
Subject: [PATCH v2] dm9000: define debug level as a module parameter
Date: Fri, 19 Aug 2011 23:31:40 +0300
Message-ID: <1313785900-27367-1-git-send-email-vz@mleia.com>
Cc: netdev@vger.kernel.org, Ben Dooks <ben-linux@fluff.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from li271-223.members.linode.com ([178.79.152.223]:60497 "EHLO
	mail.mleia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752187Ab1HSUb7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Aug 2011 16:31:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change allows to get driver specific debug messages output
providing a module parameter. As far as the maximum level of verbosity
is too high, it is demoted by default.

Signed-off-by: Vladimir Zapolskiy <vz@mleia.com>
Cc: Ben Dooks <ben-linux@fluff.org>
---
 drivers/net/Kconfig  |    8 --------
 drivers/net/dm9000.c |   11 ++++++++---
 2 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 8d0314d..bb0733d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -985,14 +985,6 @@ config DM9000
 	  To compile this driver as a module, choose M here.  The module
 	  will be called dm9000.
 
-config DM9000_DEBUGLEVEL
-	int "DM9000 maximum debug level"
-	depends on DM9000
-	default 4
-	help
-	  The maximum level of debugging code compiled into the DM9000
-	  driver.
-
 config DM9000_FORCE_SIMPLE_PHY_POLL
 	bool "Force simple NSR based PHY polling"
 	depends on DM9000
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 8ef31dc..4080e55 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -56,6 +56,13 @@ static int watchdog = 5000;
 module_param(watchdog, int, 0400);
 MODULE_PARM_DESC(watchdog, "transmit timeout in milliseconds");
 
+/*
+ * Debug messages level
+ */
+static int debug;
+module_param(debug, int, 0644);
+MODULE_PARM_DESC(debug, "dm9000 debug level (0-4)");
+
 /* DM9000 register address locking.
  *
  * The DM9000 uses an address register to control where data written
@@ -103,7 +110,6 @@ typedef struct board_info {
 	unsigned int	flags;
 	unsigned int	in_suspend :1;
 	unsigned int	wake_supported :1;
-	int		debug_level;
 
 	enum dm9000_type type;
 
@@ -138,8 +144,7 @@ typedef struct board_info {
 /* debug code */
 
 #define dm9000_dbg(db, lev, msg...) do {		\
-	if ((lev) < CONFIG_DM9000_DEBUGLEVEL &&		\
-	    (lev) < db->debug_level) {			\
+	if ((lev) < debug) {				\
 		dev_dbg(db->dev, msg);			\
 	}						\
 } while (0)
-- 
1.7.5.1


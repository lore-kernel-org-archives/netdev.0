From: akpm@linux-foundation.org
Subject: [patch 11/19] sis900 warning fixes
Date: Tue, 06 Mar 2007 02:41:55 -0800
Message-ID: <200703061041.l26AftIO019765@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34676 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752946AbXCFKm1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 05:42:27 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>

drivers/net/sis900.c: In function 'sis900_reset_phy':
drivers/net/sis900.c:972: warning: 'status' may be used uninitialized in this function
drivers/net/sis900.c: In function 'sis900_check_mode':
drivers/net/sis900.c:1431: warning: 'status' may be used uninitialized in this function
drivers/net/sis900.c: In function 'sis900_timer':
drivers/net/sis900.c:1467: warning: 'status' may be used uninitialized in this function


Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/sis900.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff -puN drivers/net/sis900.c~sis900-warning-fixes drivers/net/sis900.c
--- a/drivers/net/sis900.c~sis900-warning-fixes
+++ a/drivers/net/sis900.c
@@ -968,10 +968,10 @@ static void mdio_write(struct net_device
 
 static u16 sis900_reset_phy(struct net_device *net_dev, int phy_addr)
 {
-	int i = 0;
+	int i;
 	u16 status;
 
-	while (i++ < 2)
+	for (i = 0; i < 2; i++)
 		status = mdio_read(net_dev, phy_addr, MII_STATUS);
 
 	mdio_write( net_dev, phy_addr, MII_CONTROL, MII_CNTL_RESET );
@@ -1430,7 +1430,7 @@ static void sis900_auto_negotiate(struct
 	int i = 0;
 	u32 status;
 
-	while (i++ < 2)
+	for (i = 0; i < 2; i++)
 		status = mdio_read(net_dev, phy_addr, MII_STATUS);
 
 	if (!(status & MII_STAT_LINK)){
@@ -1466,9 +1466,9 @@ static void sis900_read_mode(struct net_
 	int phy_addr = sis_priv->cur_phy;
 	u32 status;
 	u16 autoadv, autorec;
-	int i = 0;
+	int i;
 
-	while (i++ < 2)
+	for (i = 0; i < 2; i++)
 		status = mdio_read(net_dev, phy_addr, MII_STATUS);
 
 	if (!(status & MII_STAT_LINK))
_

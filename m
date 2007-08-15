From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] b44: Fix MII interface of the B44 driver
Date: Wed, 15 Aug 2007 15:41:53 +0200
Message-ID: <200708151541.53903.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Aurelien Jarno <aurelien@aurel32.net>, netdev@vger.kernel.org
To: John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:40177
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755957AbXHONnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 09:43:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Aurelien Jarno <aurelien@aurel32.net>

The conversion of the B44 driver to SSB bus added the functions
__b44_{read,write}phy functions that have an argument phy_id. This gives
a way to fix the b44_mii_{read,write} functions used for MII interfaces.

The patch below does that. It allows B44 devices with integrated switch
to be configured from userland.

Signed-off-by: Aurelien Jarno <aurelien@aurel32.net>
Signed-off-by: Michael Buesch <mb@bu3sch.de>

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 36724fb..e6883f4 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -300,16 +300,11 @@ static inline int b44_writephy(struct b44 *bp, int reg, u32 val)
 }
 
 /* miilib interface */
-/* FIXME FIXME: phy_id is ignored, bp->phy_addr use is unconditional
- * due to code existing before miilib use was added to this driver.
- * Someone should remove this artificial driver limitation in
- * b44_{read,write}phy.  bp->phy_addr itself is fine (and needed).
- */
 static int b44_mii_read(struct net_device *dev, int phy_id, int location)
 {
 	u32 val;
 	struct b44 *bp = netdev_priv(dev);
-	int rc = b44_readphy(bp, location, &val);
+	int rc = __b44_readphy(bp, phy_id, location, &val);
 	if (rc)
 		return 0xffffffff;
 	return val;
@@ -319,7 +314,7 @@ static void b44_mii_write(struct net_device *dev, int phy_id, int location,
 			 int val)
 {
 	struct b44 *bp = netdev_priv(dev);
-	b44_writephy(bp, location, val);
+	__b44_writephy(bp, phy_id, location, val);
 }
 
 static int b44_phy_reset(struct b44 *bp)


-- 
Greetings Michael.

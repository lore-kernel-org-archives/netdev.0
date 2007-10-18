From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 01/13] r8169: add KERN_DEBUG to dprintk (trivial)
Date: Thu, 18 Oct 2007 22:59:53 +0200
Message-ID: <20071018205953.GB31724@electric-eye.fr.zoreil.com>
References: <20071018204846.GC8594@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Joe Perches <joe@perches.com>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40469 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758112AbXJRVEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 17:04:25 -0400
Content-Disposition: inline
In-Reply-To: <20071018204846.GC8594@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- prefix dprintk with KERN_DEBUG
- fix a bug with existing use of dprintk (PFX KERN_INFO PFX)

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 419c00c..94b79f5 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -44,7 +44,8 @@
 		printk( "Assertion failed! %s,%s,%s,line=%d\n",	\
 		#expr,__FILE__,__FUNCTION__,__LINE__);		\
 	}
-#define dprintk(fmt, args...)	do { printk(PFX fmt, ## args); } while (0)
+#define dprintk(fmt, args...) \
+	do { printk(KERN_DEBUG PFX fmt, ## args); } while (0)
 #else
 #define assert(expr) do {} while (0)
 #define dprintk(fmt, args...)	do {} while (0)
@@ -1933,7 +1934,7 @@ static void rtl_hw_start_8169(struct net_device *dev)
 
 	if ((tp->mac_version == RTL_GIGA_MAC_VER_02) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_03)) {
-		dprintk(KERN_INFO PFX "Set MAC Reg C+CR Offset 0xE0. "
+		dprintk("Set MAC Reg C+CR Offset 0xE0. "
 			"Bit-3 and bit-14 MUST be 1\n");
 		tp->cp_cmd |= (1 << 14);
 	}
-- 
1.5.2.4


From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] r8169 - trivial fixes - add KERN_DEBUG to dprintk
Date: Thu, 18 Oct 2007 12:01:37 -0700
Message-ID: <1192734097.23980.37.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3130 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758698AbXJRTBs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2007 15:01:48 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prefix dprintk with KERN_DEBUG
Fix a bug with existing use of dprintk (PFX KERN_INFO PFX)

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 419c00c..9c11087 100644
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



From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH] Fix broken RBTX4927 support in ne.c
Date: Thu, 01 Mar 2007 01:22:23 +0900 (JST)
Message-ID: <20070301.012223.129448787.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, sshtylyov@ru.mvista.com,
	netdev@vger.kernel.org
To: linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([210.190.142.172]:54246 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751821AbXB1QWZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 11:22:25 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are some ifdefs for RBTX4927, but need some more bits.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index a5c4199..02cc78b 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -55,8 +55,10 @@ static const char version2[] =
 #include <asm/system.h>
 #include <asm/io.h>
 
-#if defined(CONFIG_TOSHIBA_RBTX4927) || defined(CONFIG_TOSHIBA_RBTX4938)
+#if defined(CONFIG_TOSHIBA_RBTX4938)
 #include <asm/tx4938/rbtx4938.h>
+#elif defined(CONFIG_TOSHIBA_RBTX4927)
+#include <asm/tx4927/toshiba_rbtx4927.h>
 #endif
 
 #include "8390.h"
@@ -229,6 +231,9 @@ struct net_device * __init ne_probe(int unit)
 #ifdef CONFIG_TOSHIBA_RBTX4938
 	dev->base_addr = RBTX4938_RTL_8019_BASE;
 	dev->irq = RBTX4938_RTL_8019_IRQ;
+#elif defined(CONFIG_TOSHIBA_RBTX4927)
+	dev->base_addr = RBTX4927_RTL_8019_BASE;
+	dev->irq = RBTX4927_RTL_8019_IRQ;
 #endif
 	err = do_ne_probe(dev);
 	if (err)

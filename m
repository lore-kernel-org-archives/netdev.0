From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] e1000: fix sparse warning
Date: Wed, 23 Feb 2011 10:12:03 -0800
Message-ID: <20110223101203.0894c474@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59460 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752005Ab1BWSMG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 13:12:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sparse complains because the e1000 driver is calling ioread on a pointer
not tagged as __iomem.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/e1000/e1000_osdep.h	2011-02-23 10:00:31.496097384 -0800
+++ b/drivers/net/e1000/e1000_osdep.h	2011-02-23 10:00:47.740287665 -0800
@@ -42,7 +42,8 @@
 #define GBE_CONFIG_RAM_BASE \
 	((unsigned int)(CONFIG_RAM_BASE + GBE_CONFIG_OFFSET))
 
-#define GBE_CONFIG_BASE_VIRT    phys_to_virt(GBE_CONFIG_RAM_BASE)
+#define GBE_CONFIG_BASE_VIRT \
+	((void __iomem *)phys_to_virt(GBE_CONFIG_RAM_BASE))
 
 #define GBE_CONFIG_FLASH_WRITE(base, offset, count, data) \
 	(iowrite16_rep(base + offset, data, count))

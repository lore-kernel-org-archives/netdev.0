From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 1/3] e1000: fix sparse warning
Date: Wed,  2 Mar 2011 03:45:39 -0800
Message-ID: <1299066341-13820-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299066341-13820-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:21428 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756883Ab1CBLqo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 06:46:44 -0500
In-Reply-To: <1299066341-13820-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>

Sparse complains because the e1000 driver is calling ioread on a pointer
not tagged as __iomem.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Reviewed-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000/e1000_osdep.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_osdep.h b/drivers/net/e1000/e1000_osdep.h
index 55c1711..33e7c45a 100644
--- a/drivers/net/e1000/e1000_osdep.h
+++ b/drivers/net/e1000/e1000_osdep.h
@@ -42,7 +42,8 @@
 #define GBE_CONFIG_RAM_BASE \
 	((unsigned int)(CONFIG_RAM_BASE + GBE_CONFIG_OFFSET))
 
-#define GBE_CONFIG_BASE_VIRT    phys_to_virt(GBE_CONFIG_RAM_BASE)
+#define GBE_CONFIG_BASE_VIRT \
+	((void __iomem *)phys_to_virt(GBE_CONFIG_RAM_BASE))
 
 #define GBE_CONFIG_FLASH_WRITE(base, offset, count, data) \
 	(iowrite16_rep(base + offset, data, count))
-- 
1.7.4


From: Josh Boyer <jwboyer@gmail.com>
Subject: [PATCH] net: enic: include irq.h for irqreturn_t definitions
Date: Wed, 2 Apr 2014 11:24:00 -0400
Message-ID: <20140402152400.GC20438@zod>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christian Benvenuti <benve@cisco.com>,
	Sujith Sankar <ssujith@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:41175 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758696AbaDBPYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 11:24:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The enic driver fails to build on ARM with:

In file included from drivers/net/ethernet/cisco/enic/enic_res.c:40:0:
drivers/net/ethernet/cisco/enic/enic.h:48:2: error: expected specifier-qualifier-list before 'irqreturn_t'
  irqreturn_t (*isr)(int, void *);
  ^

Nothing in the driver is explicitly including the irq definitions, so we add
an include of linux/irq.h to pick them up.

Signed-off-by: Josh Boyer <jwboyer@fedoraproject.org>
---
 drivers/net/ethernet/cisco/enic/enic.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index e9f7c656ddda..e35c8e0202ad 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -29,6 +29,7 @@
 #include "vnic_stats.h"
 #include "vnic_nic.h"
 #include "vnic_rss.h"
+#include <linux/irq.h>
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-- 
1.8.5.3

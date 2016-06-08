From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] net: Reduce queue allocation to one in kdump kernel
Date: Wed,  8 Jun 2016 18:09:08 +0530
Message-ID: <1465389548-7651-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.32.117.8] ([12.32.117.8]:31904 "EHLO
	stargate3.asicdesigners.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1161246AbcFHMd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 08:33:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When in kdump kernel, reduce memory usage by only using a single Queue
Set for multiqueue devices. So make netif_get_num_default_rss_queues()
return one, when in kdump kernel.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 net/core/dev.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 904ff431d570..161c4627a798 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -139,6 +139,7 @@
 #include <linux/hrtimer.h>
 #include <linux/netfilter_ingress.h>
 #include <linux/sctp.h>
+#include <linux/crash_dump.h>
 
 #include "net-sysfs.h"
 
@@ -2249,7 +2250,8 @@ EXPORT_SYMBOL(netif_set_real_num_rx_queues);
  */
 int netif_get_num_default_rss_queues(void)
 {
-	return min_t(int, DEFAULT_MAX_NUM_RSS_QUEUES, num_online_cpus());
+	return is_kdump_kernel() ?
+		1 : min_t(int, DEFAULT_MAX_NUM_RSS_QUEUES, num_online_cpus());
 }
 EXPORT_SYMBOL(netif_get_num_default_rss_queues);
 
-- 
2.3.4

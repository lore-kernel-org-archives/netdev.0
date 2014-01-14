From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 net-next 1/4] flowcache: Namespacify flowcache global parameters with xfrm
Date: Tue, 14 Jan 2014 09:39:44 +0800
Message-ID: <1389663588-29678-2-git-send-email-fan.du@windriver.com>
References: <1389663588-29678-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:64683 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753237AbaANBjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 20:39:43 -0500
In-Reply-To: <1389663588-29678-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since flowcache is tightly coupled with IPsec, so it would be
easier to put flow cache global parameters here into xfrm
namespace part.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 include/net/netns/xfrm.h |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 1006a26..52d0086 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -6,6 +6,7 @@
 #include <linux/workqueue.h>
 #include <linux/xfrm.h>
 #include <net/dst_ops.h>
+#include <net/flowcache.h>
 
 struct ctl_table_header;
 
@@ -61,6 +62,16 @@ struct netns_xfrm {
 	spinlock_t xfrm_policy_sk_bundle_lock;
 	rwlock_t xfrm_policy_lock;
 	struct mutex xfrm_cfg_mutex;
+
+	/* flow cache part */
+	struct flow_cache	flow_cache_global;
+	struct kmem_cache	*flow_cachep;
+	atomic_t		flow_cache_genid;
+	struct list_head	flow_cache_gc_list;
+	spinlock_t		flow_cache_gc_lock;
+	struct work_struct	flow_cache_gc_work;
+	struct work_struct	flow_cache_flush_work;
+	struct mutex		flow_flush_sem;
 };
 
 #endif
-- 
1.7.9.5

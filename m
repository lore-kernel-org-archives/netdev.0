From: xiao jin <jin.xiao@intel.com>
Subject: [PATCH] inetpeer_gc_worker: trivial cleanup
Date: Fri, 25 Apr 2014 08:53:29 +0800
Message-ID: <1398387209-12322-1-git-send-email-jin.xiao@intel.com>
Cc: david.a.cohen@linux.intel.com, xiao jin <jin.xiao@intel.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, trivial@kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do not initialize list twice.
list_replace_init() already takes care of initializing list.
We don't need to initialize it with LIST_HEAD() beforehand.

Signed-off-by: xiao jin <jin.xiao@intel.com>
Reviewed-by: David Cohen <david.a.cohen@linux.intel.com>
---
 net/ipv4/inetpeer.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 48f4244..c98cf14 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -120,7 +120,7 @@ int inet_peer_maxttl __read_mostly = 10 * 60 * HZ;	/* usual time to live: 10 min
 static void inetpeer_gc_worker(struct work_struct *work)
 {
 	struct inet_peer *p, *n, *c;
-	LIST_HEAD(list);
+	struct list_head list;
 
 	spin_lock_bh(&gc_lock);
 	list_replace_init(&gc_list, &list);
-- 
1.7.9.5

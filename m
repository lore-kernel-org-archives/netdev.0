From: xiao jin <jin.xiao@intel.com>
Subject: [PATCH] cleanup_net: trivial cleanup
Date: Fri, 25 Apr 2014 08:50:54 +0800
Message-ID: <1398387054-11172-1-git-send-email-jin.xiao@intel.com>
Cc: david.a.cohen@linux.intel.com, xiao jin <jin.xiao@intel.com>
To: davem@davemloft.net, trivial@kernel.org, ebiederm@xmission.com,
	dhowells@redhat.com, viro@zeniv.linux.org.uk,
	serge.hallyn@canonical.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do not initialize net_kill_list twice.
list_replace_init() already takes care of initializing net_kill_list.
We don't need to initialize it with LIST_HEAD() beforehand.

Signed-off-by: xiao jin <jin.xiao@intel.com>
Reviewed-by: David Cohen <david.a.cohen@linux.intel.com>
---
 net/core/net_namespace.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 81d3a9a..05e949d 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -273,7 +273,7 @@ static void cleanup_net(struct work_struct *work)
 {
 	const struct pernet_operations *ops;
 	struct net *net, *tmp;
-	LIST_HEAD(net_kill_list);
+	struct list_head net_kill_list;
 	LIST_HEAD(net_exit_list);
 
 	/* Atomically snapshot the list of namespaces to cleanup */
-- 
1.7.9.5

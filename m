From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] netns: move {inc,dec}_net_namespaces into #ifdef
Date: Fri, 23 Sep 2016 18:06:12 +0200
Message-ID: <20160923160650.3631870-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        WANG Cong <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the newly enforced limit on the number of namespaces,
we get a build warning if CONFIG_NETNS is disabled:

net/core/net_namespace.c:273:13: error: 'dec_net_namespaces' defined but not used [-Werror=unused-function]
net/core/net_namespace.c:268:24: error: 'inc_net_namespaces' defined but not used [-Werror=unused-function]

This moves the two added functions inside the #ifdef that guards
their callers.

Fixes: 703286608a22 ("netns: Add a limit on the number of net namespaces")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/core/net_namespace.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index d0eb13d3226b..989434f36f96 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -265,16 +265,6 @@ struct net *get_net_ns_by_id(struct net *net, int id)
 	return peer;
 }
 
-static struct ucounts *inc_net_namespaces(struct user_namespace *ns)
-{
-	return inc_ucount(ns, current_euid(), UCOUNT_NET_NAMESPACES);
-}
-
-static void dec_net_namespaces(struct ucounts *ucounts)
-{
-	dec_ucount(ucounts, UCOUNT_NET_NAMESPACES);
-}
-
 /*
  * setup_net runs the initializers for the network namespace object.
  */
@@ -319,6 +309,16 @@ static __net_init int setup_net(struct net *net, struct user_namespace *user_ns)
 
 
 #ifdef CONFIG_NET_NS
+static struct ucounts *inc_net_namespaces(struct user_namespace *ns)
+{
+	return inc_ucount(ns, current_euid(), UCOUNT_NET_NAMESPACES);
+}
+
+static void dec_net_namespaces(struct ucounts *ucounts)
+{
+	dec_ucount(ucounts, UCOUNT_NET_NAMESPACES);
+}
+
 static struct kmem_cache *net_cachep;
 static struct workqueue_struct *netns_wq;
 
-- 
2.9.0

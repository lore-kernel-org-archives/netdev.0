From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [RFC v2 01/04] net: make net_create() globally visible
Date: Sun, 12 Jun 2011 18:43:43 +0400
Message-ID: <1307889823-6169-1-git-send-email-segoon@openwall.com>
Cc: kernel-hardening@lists.openwall.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make net_create() visible outside of net/core/net_namespace.c to be able
to create additional network namespaces inside of fs/proc/proc_net.c.

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
---
 include/net/net_namespace.h |    2 ++
 net/core/net_namespace.c    |    2 +-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 1bf812b..d40c61c 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -113,6 +113,8 @@ static inline struct net *copy_net_ns(unsigned long flags, struct net *net_ns)
 }
 #endif /* CONFIG_NET */
 
+extern struct net *net_create(void);
+
 
 extern struct list_head net_namespace_list;
 
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 3f86026..c7c7310 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -216,7 +216,7 @@ static void net_free(struct net *net)
 	kmem_cache_free(net_cachep, net);
 }
 
-static struct net *net_create(void)
+struct net *net_create(void)
 {
 	struct net *net;
 	int rv;

From: kaber@trash.net
Subject: [PATCH 03/17] netfilter: vmalloc_node cleanup
Date: Tue, 15 Jun 2010 17:38:29 +0200
Message-ID: <1276616323-20880-4-git-send-email-kaber@trash.net>
References: <1276616323-20880-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1276616323-20880-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>

Using vmalloc_node(size, numa_node_id()) for temporary storage is not
needed. vmalloc(size) is more respectful of user NUMA policy.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/arp_tables.c |    7 +++----
 net/ipv4/netfilter/ip_tables.c  |    4 ++--
 net/ipv6/netfilter/ip6_tables.c |    7 +++----
 3 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 1ac01b1..16c0ba0 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -758,7 +758,7 @@ static struct xt_counters *alloc_counters(const struct xt_table *table)
 	 * about).
 	 */
 	countersize = sizeof(struct xt_counters) * private->number;
-	counters = vmalloc_node(countersize, numa_node_id());
+	counters = vmalloc(countersize);
 
 	if (counters == NULL)
 		return ERR_PTR(-ENOMEM);
@@ -1005,8 +1005,7 @@ static int __do_replace(struct net *net, const char *name,
 	struct arpt_entry *iter;
 
 	ret = 0;
-	counters = vmalloc_node(num_counters * sizeof(struct xt_counters),
-				numa_node_id());
+	counters = vmalloc(num_counters * sizeof(struct xt_counters));
 	if (!counters) {
 		ret = -ENOMEM;
 		goto out;
@@ -1159,7 +1158,7 @@ static int do_add_counters(struct net *net, const void __user *user,
 	if (len != size + num_counters * sizeof(struct xt_counters))
 		return -EINVAL;
 
-	paddc = vmalloc_node(len - size, numa_node_id());
+	paddc = vmalloc(len - size);
 	if (!paddc)
 		return -ENOMEM;
 
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 63958f3..7c0b8ad 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -928,7 +928,7 @@ static struct xt_counters *alloc_counters(const struct xt_table *table)
 	   (other than comefrom, which userspace doesn't care
 	   about). */
 	countersize = sizeof(struct xt_counters) * private->number;
-	counters = vmalloc_node(countersize, numa_node_id());
+	counters = vmalloc(countersize);
 
 	if (counters == NULL)
 		return ERR_PTR(-ENOMEM);
@@ -1352,7 +1352,7 @@ do_add_counters(struct net *net, const void __user *user,
 	if (len != size + num_counters * sizeof(struct xt_counters))
 		return -EINVAL;
 
-	paddc = vmalloc_node(len - size, numa_node_id());
+	paddc = vmalloc(len - size);
 	if (!paddc)
 		return -ENOMEM;
 
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 6f517bd..82945ef 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -943,7 +943,7 @@ static struct xt_counters *alloc_counters(const struct xt_table *table)
 	   (other than comefrom, which userspace doesn't care
 	   about). */
 	countersize = sizeof(struct xt_counters) * private->number;
-	counters = vmalloc_node(countersize, numa_node_id());
+	counters = vmalloc(countersize);
 
 	if (counters == NULL)
 		return ERR_PTR(-ENOMEM);
@@ -1213,8 +1213,7 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 	struct ip6t_entry *iter;
 
 	ret = 0;
-	counters = vmalloc_node(num_counters * sizeof(struct xt_counters),
-				numa_node_id());
+	counters = vmalloc(num_counters * sizeof(struct xt_counters));
 	if (!counters) {
 		ret = -ENOMEM;
 		goto out;
@@ -1368,7 +1367,7 @@ do_add_counters(struct net *net, const void __user *user, unsigned int len,
 	if (len != size + num_counters * sizeof(struct xt_counters))
 		return -EINVAL;
 
-	paddc = vmalloc_node(len - size, numa_node_id());
+	paddc = vmalloc(len - size);
 	if (!paddc)
 		return -ENOMEM;
 
-- 
1.7.0.4


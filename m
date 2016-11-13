From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/39] netfilter: ipset: Mark some helper args as const.
Date: Sun, 13 Nov 2016 23:25:11 +0100
Message-ID: <1479075933-4491-18-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Mark some of the helpers arguments as const.

Ported from a patch proposed by Sergey Popovich <popovich_sergei@mail.ua>.

Suggested-by: Sergey Popovich <popovich_sergei@mail.ua>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h         | 4 ++--
 include/linux/netfilter/ipset/ip_set_comment.h | 2 +-
 include/linux/netfilter/ipset/ip_set_timeout.h | 4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 5b1fd090f34b..524467f933bf 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -346,7 +346,7 @@ ip_set_get_skbinfo(struct ip_set_skbinfo *skbinfo,
 }
 
 static inline bool
-ip_set_put_skbinfo(struct sk_buff *skb, struct ip_set_skbinfo *skbinfo)
+ip_set_put_skbinfo(struct sk_buff *skb, const struct ip_set_skbinfo *skbinfo)
 {
 	/* Send nonzero parameters only */
 	return ((skbinfo->skbmark || skbinfo->skbmarkmask) &&
@@ -373,7 +373,7 @@ ip_set_init_skbinfo(struct ip_set_skbinfo *skbinfo,
 }
 
 static inline bool
-ip_set_put_counter(struct sk_buff *skb, struct ip_set_counter *counter)
+ip_set_put_counter(struct sk_buff *skb, const struct ip_set_counter *counter)
 {
 	return nla_put_net64(skb, IPSET_ATTR_BYTES,
 			     cpu_to_be64(ip_set_get_bytes(counter)),
diff --git a/include/linux/netfilter/ipset/ip_set_comment.h b/include/linux/netfilter/ipset/ip_set_comment.h
index 8d0248525957..bae5c7609be2 100644
--- a/include/linux/netfilter/ipset/ip_set_comment.h
+++ b/include/linux/netfilter/ipset/ip_set_comment.h
@@ -43,7 +43,7 @@ ip_set_init_comment(struct ip_set_comment *comment,
 
 /* Used only when dumping a set, protected by rcu_read_lock_bh() */
 static inline int
-ip_set_put_comment(struct sk_buff *skb, struct ip_set_comment *comment)
+ip_set_put_comment(struct sk_buff *skb, const struct ip_set_comment *comment)
 {
 	struct ip_set_comment_rcu *c = rcu_dereference_bh(comment->c);
 
diff --git a/include/linux/netfilter/ipset/ip_set_timeout.h b/include/linux/netfilter/ipset/ip_set_timeout.h
index 1d6a935c1ac5..bfb3531fd88a 100644
--- a/include/linux/netfilter/ipset/ip_set_timeout.h
+++ b/include/linux/netfilter/ipset/ip_set_timeout.h
@@ -40,7 +40,7 @@ ip_set_timeout_uget(struct nlattr *tb)
 }
 
 static inline bool
-ip_set_timeout_expired(unsigned long *t)
+ip_set_timeout_expired(const unsigned long *t)
 {
 	return *t != IPSET_ELEM_PERMANENT && time_is_before_jiffies(*t);
 }
@@ -63,7 +63,7 @@ ip_set_timeout_set(unsigned long *timeout, u32 value)
 }
 
 static inline u32
-ip_set_timeout_get(unsigned long *timeout)
+ip_set_timeout_get(const unsigned long *timeout)
 {
 	return *timeout == IPSET_ELEM_PERMANENT ? 0 :
 		jiffies_to_msecs(*timeout - jiffies)/MSEC_PER_SEC;
-- 
2.1.4


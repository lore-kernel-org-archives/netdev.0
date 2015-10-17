From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/35] netfilter: ctnetlink: add const qualifier to nfnl_hook.get_ct
Date: Sat, 17 Oct 2015 13:32:43 +0200
Message-ID: <1445081590-2924-9-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>

get_ct as is and will not update its skb argument, and users of
nfnl_ct_hook is currently only nfqueue, we can add const qualifier.

Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
---
 include/linux/netfilter.h            | 2 +-
 net/netfilter/nf_conntrack_netlink.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 27747de..edb3dc3 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -378,7 +378,7 @@ enum ip_conntrack_info;
 struct nlattr;
 
 struct nfnl_ct_hook {
-	struct nf_conn *(*get_ct)(struct sk_buff *skb,
+	struct nf_conn *(*get_ct)(const struct sk_buff *skb,
 				  enum ip_conntrack_info *ctinfo);
 	size_t (*build_size)(const struct nf_conn *ct);
 	int (*build)(struct sk_buff *skb, struct nf_conn *ct,
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 71d6ada..9f52729 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2162,7 +2162,7 @@ ctnetlink_glue_build_size(const struct nf_conn *ct)
 	       ;
 }
 
-static struct nf_conn *ctnetlink_glue_get_ct(struct sk_buff *skb,
+static struct nf_conn *ctnetlink_glue_get_ct(const struct sk_buff *skb,
 					     enum ip_conntrack_info *ctinfo)
 {
 	struct nf_conn *ct;
-- 
2.1.4


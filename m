From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/7] netfilter: nfnetlink: use list_for_each_entry_safe to delete all objects
Date: Tue, 30 Aug 2016 13:26:18 +0200
Message-ID: <1472556383-6787-3-git-send-email-pablo@netfilter.org>
References: <1472556383-6787-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1472556383-6787-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <liping.zhang@spreadtrum.com>

cttimeout and acct objects are deleted from the list while traversing
it, so use list_for_each_entry is unsafe here.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_acct.c      | 6 +++---
 net/netfilter/nfnetlink_cttimeout.c | 5 +++--
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index 70eb2f6a..d44d89b 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -343,12 +343,12 @@ static int nfnl_acct_del(struct net *net, struct sock *nfnl,
 			 struct sk_buff *skb, const struct nlmsghdr *nlh,
 			 const struct nlattr * const tb[])
 {
-	char *acct_name;
-	struct nf_acct *cur;
+	struct nf_acct *cur, *tmp;
 	int ret = -ENOENT;
+	char *acct_name;
 
 	if (!tb[NFACCT_NAME]) {
-		list_for_each_entry(cur, &net->nfnl_acct_list, head)
+		list_for_each_entry_safe(cur, tmp, &net->nfnl_acct_list, head)
 			nfnl_acct_try_del(cur);
 
 		return 0;
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 68216cd..f74fee1 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -350,12 +350,13 @@ static int cttimeout_del_timeout(struct net *net, struct sock *ctnl,
 				 const struct nlmsghdr *nlh,
 				 const struct nlattr * const cda[])
 {
-	struct ctnl_timeout *cur;
+	struct ctnl_timeout *cur, *tmp;
 	int ret = -ENOENT;
 	char *name;
 
 	if (!cda[CTA_TIMEOUT_NAME]) {
-		list_for_each_entry(cur, &net->nfct_timeout_list, head)
+		list_for_each_entry_safe(cur, tmp, &net->nfct_timeout_list,
+					 head)
 			ctnl_timeout_try_del(net, cur);
 
 		return 0;
-- 
2.1.4


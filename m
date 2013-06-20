From: Zhao Hongjiang <zhaohongjiang@huawei.com>
Subject: [PATCH 2/5] net: netfilter: using strlcpy instead of strncpy
Date: Thu, 20 Jun 2013 18:49:42 +0800
Message-ID: <1371725385-11540-2-git-send-email-zhaohongjiang@huawei.com>
References: <1371725385-11540-1-git-send-email-zhaohongjiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<netdev@vger.kernel.org>, Zhao Hongjiang <zhaohongjiang@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:28810 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757188Ab3FTKwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 06:52:02 -0400
In-Reply-To: <1371725385-11540-1-git-send-email-zhaohongjiang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

for NUL terminated string, need alway set '\0' in the end.

Signed-off-by: Zhao Hongjiang <zhaohongjiang@huawei.com>
---
 net/netfilter/ipset/ip_set_core.c |   12 ++++++------
 net/netfilter/nfnetlink_acct.c    |    2 +-
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index f771390..d70895b 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1010,7 +1010,7 @@ ip_set_rename(struct sock *ctnl, struct sk_buff *skb,
 			goto out;
 		}
 	}
-	strncpy(set->name, name2, IPSET_MAXNAMELEN);
+	strlcpy(set->name, name2, sizeof(set->name));
 
 out:
 	read_unlock_bh(&ip_set_ref_lock);
@@ -1055,9 +1055,9 @@ ip_set_swap(struct sock *ctnl, struct sk_buff *skb,
 	      from->type->family == to->type->family))
 		return -IPSET_ERR_TYPE_MISMATCH;
 
-	strncpy(from_name, from->name, IPSET_MAXNAMELEN);
-	strncpy(from->name, to->name, IPSET_MAXNAMELEN);
-	strncpy(to->name, from_name, IPSET_MAXNAMELEN);
+	strlcpy(from_name, from->name, sizeof(from_name));
+	strlcpy(from->name, to->name, sizeof(from->name));
+	strlcpy(to->name, from_name, sizeof(to->name));
 
 	write_lock_bh(&ip_set_ref_lock);
 	swap(from->ref, to->ref);
@@ -1800,8 +1800,8 @@ ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
 		}
 		nfnl_lock(NFNL_SUBSYS_IPSET);
 		set = nfnl_set(req_get->set.index);
-		strncpy(req_get->set.name, set ? set->name : "",
-			IPSET_MAXNAMELEN);
+		strlcpy(req_get->set.name, set ? set->name : "",
+			sizeof(req_get->set.name));
 		nfnl_unlock(NFNL_SUBSYS_IPSET);
 		goto copy;
 	}
diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index c7b6d46..520247b 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -77,7 +77,7 @@ nfnl_acct_new(struct sock *nfnl, struct sk_buff *skb,
 	if (nfacct == NULL)
 		return -ENOMEM;
 
-	strncpy(nfacct->name, nla_data(tb[NFACCT_NAME]), NFACCT_NAME_MAX);
+	strlcpy(nfacct->name, nla_data(tb[NFACCT_NAME]), sizeof(nfacct->name));
 
 	if (tb[NFACCT_BYTES]) {
 		atomic64_set(&nfacct->bytes,
-- 
1.7.1

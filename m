From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/5] netfilter: nfnetlink_acct: return -EINVAL if object name is empty
Date: Thu,  4 Apr 2013 14:56:07 +0200
Message-ID: <1365080169-6880-4-git-send-email-pablo@netfilter.org>
References: <1365080169-6880-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1365080169-6880-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If user-space tries to create accounting object with an empty
name, then return -EINVAL.

Reported-by: Michael Zintakis <michael.zintakis@googlemail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_acct.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index 589d686..dc3fd5d 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -49,6 +49,8 @@ nfnl_acct_new(struct sock *nfnl, struct sk_buff *skb,
 		return -EINVAL;
 
 	acct_name = nla_data(tb[NFACCT_NAME]);
+	if (strlen(acct_name) == 0)
+		return -EINVAL;
 
 	list_for_each_entry(nfacct, &nfnl_acct_list, head) {
 		if (strncmp(nfacct->name, acct_name, NFACCT_NAME_MAX) != 0)
-- 
1.7.10.4


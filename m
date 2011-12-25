From: pablo@netfilter.org
Subject: [PATCH 08/19] netfilter: ctnetlink: support individual atomic-get-and-reset of counters
Date: Sun, 25 Dec 2011 02:57:24 +0100
Message-ID: <1324778255-2830-9-git-send-email-pablo@netfilter.org>
References: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This allows to use the get operation to atomically get-and-reset
counters.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 77d209c..636617c 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1015,6 +1015,17 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	if (err < 0)
 		goto out;
 
+	if (NFNL_MSG_TYPE(nlh->nlmsg_type) == IPCTNL_MSG_CT_GET_CTRZERO) {
+		struct nf_conn_counter *acct;
+
+		acct = nf_conn_acct_find(ct);
+		if (acct) {
+			atomic64_set(&acct[IP_CT_DIR_ORIGINAL].bytes, 0);
+			atomic64_set(&acct[IP_CT_DIR_ORIGINAL].packets, 0);
+			atomic64_set(&acct[IP_CT_DIR_REPLY].bytes, 0);
+			atomic64_set(&acct[IP_CT_DIR_REPLY].packets, 0);
+		}
+	}
 	return 0;
 
 free:
-- 
1.7.2.5


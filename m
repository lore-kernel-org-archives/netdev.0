From: pablo@netfilter.org
Subject: [PATCH 2/2] netfilter: ctnetlink: fix timeout calculation
Date: Sat, 31 Dec 2011 17:22:47 +0100
Message-ID: <1325348567-4251-3-git-send-email-pablo@netfilter.org>
References: <1325348567-4251-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1325348567-4251-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xi Wang <xi.wang@gmail.com>

The sanity check (timeout < 0) never works; the dividend is unsigned
and so is the division, which should have been a signed division.

	long timeout = (ct->timeout.expires - jiffies) / HZ;
	if (timeout < 0)
		timeout = 0;

This patch converts the time values to signed for the division.

Signed-off-by: Xi Wang <xi.wang@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index b697777..257e772 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -135,7 +135,7 @@ nla_put_failure:
 static inline int
 ctnetlink_dump_timeout(struct sk_buff *skb, const struct nf_conn *ct)
 {
-	long timeout = (ct->timeout.expires - jiffies) / HZ;
+	long timeout = ((long)ct->timeout.expires - (long)jiffies) / HZ;
 
 	if (timeout < 0)
 		timeout = 0;
@@ -1641,7 +1641,7 @@ ctnetlink_exp_dump_expect(struct sk_buff *skb,
 			  const struct nf_conntrack_expect *exp)
 {
 	struct nf_conn *master = exp->master;
-	long timeout = (exp->timeout.expires - jiffies) / HZ;
+	long timeout = ((long)exp->timeout.expires - (long)jiffies) / HZ;
 	struct nf_conn_help *help;
 
 	if (timeout < 0)
-- 
1.7.7.3


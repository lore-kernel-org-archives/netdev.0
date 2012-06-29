From: pablo@netfilter.org
Subject: [PATCH 4/5] netfilter: ipset: fix crash if IPSET_CMD_NONE command is sent
Date: Fri, 29 Jun 2012 17:37:34 +0200
Message-ID: <1340984255-738-5-git-send-email-pablo@netfilter.org>
References: <1340984255-738-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1340984255-738-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>

This patch fixes a crash if that ipset command is sent over nfnetlink.

Signed-off-by: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_core.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 819c342..9730882 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -640,6 +640,14 @@ find_free_id(const char *name, ip_set_id_t *index, struct ip_set **set)
 }
 
 static int
+ip_set_none(struct sock *ctnl, struct sk_buff *skb,
+	    const struct nlmsghdr *nlh,
+	    const struct nlattr * const attr[])
+{
+	return -EOPNOTSUPP;
+}
+
+static int
 ip_set_create(struct sock *ctnl, struct sk_buff *skb,
 	      const struct nlmsghdr *nlh,
 	      const struct nlattr * const attr[])
@@ -1539,6 +1547,10 @@ nlmsg_failure:
 }
 
 static const struct nfnl_callback ip_set_netlink_subsys_cb[IPSET_MSG_MAX] = {
+	[IPSET_CMD_NONE]	= {
+		.call		= ip_set_none,
+		.attr_count	= IPSET_ATTR_CMD_MAX,
+	},
 	[IPSET_CMD_CREATE]	= {
 		.call		= ip_set_create,
 		.attr_count	= IPSET_ATTR_CMD_MAX,
-- 
1.7.10


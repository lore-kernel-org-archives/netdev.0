From: pablo@netfilter.org
Subject: [PATCH 4/4] netfilter: ctnetlink: fix compilation with NF_CONNTRACK_EVENTS=n
Date: Sun, 24 Jun 2012 01:53:29 +0200
Message-ID: <1340495609-26250-5-git-send-email-pablo@netfilter.org>
References: <1340495609-26250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1340495609-26250-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch fixes compilation with NF_CONNTRACK_EVENTS=n and
NETFILTER_NETLINK_QUEUE_CT=y.

I'm leaving all those static inline functions that calculate the size
of the event message out of the ifdef area of NF_CONNTRACK_EVENTS since
they will not be included by gcc in case they are unused.

Reported-by: Randy Dunlap <rdunlap@xenotime.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 8bb4733..b9b8f4a 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -478,7 +478,6 @@ nla_put_failure:
 	return -1;
 }
 
-#ifdef CONFIG_NF_CONNTRACK_EVENTS
 static inline size_t
 ctnetlink_proto_size(const struct nf_conn *ct)
 {
@@ -565,6 +564,7 @@ ctnetlink_nlmsg_size(const struct nf_conn *ct)
 	       ;
 }
 
+#ifdef CONFIG_NF_CONNTRACK_EVENTS
 static int
 ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 {
-- 
1.7.10


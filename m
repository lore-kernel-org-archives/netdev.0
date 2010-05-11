From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] net/: (netfilter related) Remove unnecessary
 returns from void function()s
Date: Tue, 11 May 2010 10:52:26 -0700
Message-ID: <1273600346.20514.247.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2148 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750939Ab0EKRw2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 May 2010 13:52:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes from net/ netfilter files
all the unnecessary return; statements that precede the
last closing brace of void functions.

It does not remove the returns that are immediately
preceded by a label as gcc doesn't like that.

Done via:
$ grep -rP --include=*.[ch] -l "return;\n}" net/ | \
  xargs perl -i -e 'local $/ ; while (<>) { s/\n[ \t\n]+return;\n}/\n}/g; print; }'

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv4/netfilter/ip_queue.c                  |    1 -
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    1 -
 net/ipv4/netfilter/nf_nat_proto_gre.c          |    1 -
 net/ipv6/netfilter/ip6_queue.c                 |    1 -
 net/netfilter/nf_conntrack_netlink.c           |    1 -
 net/netfilter/nf_queue.c                       |    1 -
 net/netfilter/xt_time.c                        |    1 -
 7 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index c838238..a4e5fc5 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -461,7 +461,6 @@ __ipq_rcv_skb(struct sk_buff *skb)
 
 	if (flags & NLM_F_ACK)
 		netlink_ack(skb, nlh, 0);
-	return;
 }
 
 static void
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 2bb1f87..33cc9f2 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -452,6 +452,5 @@ module_exit(nf_conntrack_l3proto_ipv4_fini);
 
 void need_ipv4_conntrack(void)
 {
-	return;
 }
 EXPORT_SYMBOL_GPL(need_ipv4_conntrack);
diff --git a/net/ipv4/netfilter/nf_nat_proto_gre.c b/net/ipv4/netfilter/nf_nat_proto_gre.c
index d7e8920..39efbe6 100644
--- a/net/ipv4/netfilter/nf_nat_proto_gre.c
+++ b/net/ipv4/netfilter/nf_nat_proto_gre.c
@@ -144,6 +144,5 @@ module_exit(nf_nat_proto_gre_fini);
 
 void nf_nat_need_gre(void)
 {
-	return;
 }
 EXPORT_SYMBOL_GPL(nf_nat_need_gre);
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 8656eb7..8c20174 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -462,7 +462,6 @@ __ipq_rcv_skb(struct sk_buff *skb)
 
 	if (flags & NLM_F_ACK)
 		netlink_ack(skb, nlh, 0);
-	return;
 }
 
 static void
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 4e55403..354cee4 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2109,7 +2109,6 @@ static void __exit ctnetlink_exit(void)
 
 	nfnetlink_subsys_unregister(&ctnl_exp_subsys);
 	nfnetlink_subsys_unregister(&ctnl_subsys);
-	return;
 }
 
 module_init(ctnetlink_init);
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index c49ef21..0b1103c 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -279,7 +279,6 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 	}
 	rcu_read_unlock();
 	kfree(entry);
-	return;
 }
 EXPORT_SYMBOL(nf_reinject);
 
diff --git a/net/netfilter/xt_time.c b/net/netfilter/xt_time.c
index d8556fd..328eb99 100644
--- a/net/netfilter/xt_time.c
+++ b/net/netfilter/xt_time.c
@@ -148,7 +148,6 @@ static void localtime_3(struct xtm *r, time_t time)
 	}
 
 	r->month    = i + 1;
-	return;
 }
 
 static bool



From: kaber@trash.net
Subject: [PATCH 12/12] netfilter: remove unnecessary returns from void function()s
Date: Thu, 13 May 2010 18:16:25 +0200
Message-ID: <1273767385-18225-13-git-send-email-kaber@trash.net>
References: <1273767385-18225-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58079 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759325Ab0EMQQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 12:16:39 -0400
In-Reply-To: <1273767385-18225-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

This patch removes from net/ netfilter files
all the unnecessary return; statements that precede the
last closing brace of void functions.

It does not remove the returns that are immediately
preceded by a label as gcc doesn't like that.

Done via:
$ grep -rP --include=*.[ch] -l "return;\n}" net/ | \
  xargs perl -i -e 'local $/ ; while (<>) { s/\n[ \t\n]+return;\n}/\n}/g; print; }'

Signed-off-by: Joe Perches <joe@perches.com>
[Patrick: changed to keep return statements in otherwise empty function bodies]
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/ip_queue.c        |    1 -
 net/ipv6/netfilter/ip6_queue.c       |    1 -
 net/netfilter/nf_conntrack_netlink.c |    1 -
 net/netfilter/nf_queue.c             |    1 -
 net/netfilter/xt_time.c              |    1 -
 5 files changed, 0 insertions(+), 5 deletions(-)

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
index 961fb6a..c42ff6a 100644
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
index 79234bb..c48975f 100644
--- a/net/netfilter/xt_time.c
+++ b/net/netfilter/xt_time.c
@@ -148,7 +148,6 @@ static void localtime_3(struct xtm *r, time_t time)
 	}
 
 	r->month    = i + 1;
-	return;
 }
 
 static bool
-- 
1.7.0.4


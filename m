From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 47/51] netfilter: remove unneeded variable proc_net_netfilter
Date: Sat,  6 Apr 2013 14:17:46 +0200
Message-ID: <1365250670-14993-48-git-send-email-pablo@netfilter.org>
References: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39110 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1163482Ab3DFMS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Apr 2013 08:18:56 -0400
In-Reply-To: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that this supports net namespace for nflog and nfqueue,
we can remove the global proc_net_netfilter which has no
clients anymore.

Based on patch from Gao feng.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h |    5 -----
 net/netfilter/core.c      |   16 ++++------------
 2 files changed, 4 insertions(+), 17 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index ee14284..0060fde 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -289,11 +289,6 @@ nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl, u_int8_t family)
 #endif
 }
 
-#ifdef CONFIG_PROC_FS
-#include <linux/proc_fs.h>
-extern struct proc_dir_entry *proc_net_netfilter;
-#endif
-
 #else /* !CONFIG_NETFILTER */
 #define NF_HOOK(pf, hook, skb, indev, outdev, okfn) (okfn)(skb)
 #define NF_HOOK_COND(pf, hook, skb, indev, outdev, okfn, cond) (okfn)(skb)
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index b085184..7d97302 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -276,23 +276,15 @@ void (*nf_nat_decode_session_hook)(struct sk_buff *, struct flowi *);
 EXPORT_SYMBOL(nf_nat_decode_session_hook);
 #endif
 
-#ifdef CONFIG_PROC_FS
-struct proc_dir_entry *proc_net_netfilter;
-EXPORT_SYMBOL(proc_net_netfilter);
-#endif
-
 static int __net_init netfilter_net_init(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
 	net->nf.proc_netfilter = proc_net_mkdir(net, "netfilter",
 						net->proc_net);
-	if (net_eq(net, &init_net)) {
-		if (!net->nf.proc_netfilter)
-			return -ENOMEM;
-		else
-			proc_net_netfilter = net->nf.proc_netfilter;
-	} else if (!net->nf.proc_netfilter) {
-		pr_err("cannot create netfilter proc entry");
+	if (!net->nf.proc_netfilter) {
+		if (!net_eq(net, &init_net))
+			pr_err("cannot create netfilter proc entry");
+
 		return -ENOMEM;
 	}
 #endif
-- 
1.7.10.4

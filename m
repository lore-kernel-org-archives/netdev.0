From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 10/10] netfilter: remove useless variable proc_net_netfilter
Date: Thu, 7 Feb 2013 15:49:50 +0800
Message-ID: <1360223390-15589-10-git-send-email-gaofeng@cn.fujitsu.com>
References: <1360223390-15589-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: containers@lists.linux-foundation.org, pablo@netfilter.org,
	ebiederm@xmission.com, netdev@vger.kernel.org, lve@guap.ru,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1360223390-15589-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After we add net namespace support for nflog and nfqueue,
the var proc_net_netfilter has no use,just remove it.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/linux/netfilter.h | 1 -
 net/netfilter/core.c      | 7 -------
 2 files changed, 8 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index ee14284..b9d401c 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -291,7 +291,6 @@ nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl, u_int8_t family)
 
 #ifdef CONFIG_PROC_FS
 #include <linux/proc_fs.h>
-extern struct proc_dir_entry *proc_net_netfilter;
 #endif
 
 #else /* !CONFIG_NETFILTER */
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 2038673..df6e973 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -276,11 +276,6 @@ void (*nf_nat_decode_session_hook)(struct sk_buff *, struct flowi *);
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
@@ -290,8 +285,6 @@ static int __net_init netfilter_net_init(struct net *net)
 	if (net_eq(net, &init_net)) {
 		if (!net->xt.proc_netfilter)
 			panic("cannot create netfilter proc entry");
-		else
-			proc_net_netfilter = net->xt.proc_netfilter;
 	} else if (!net->xt.proc_netfilter) {
 		pr_err("cannot create netfilter proc entry");
 		return -EINVAL;
-- 
1.7.11.7


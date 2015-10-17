From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/35] netfilter: Kconfig rename QUEUE_CT to GLUE_CT
Date: Sat, 17 Oct 2015 13:32:42 +0200
Message-ID: <1445081590-2924-8-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48344 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752528AbbJQL0Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 07:26:16 -0400
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>

Conntrack information attaching infrastructure is now generic and
update it's name to use `glue' in previous patch. This patch updates
Kconfig symbol name and adding NF_CT_NETLINK dependency.

Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Kconfig                | 10 +++++-----
 net/netfilter/nf_conntrack_netlink.c |  8 ++++----
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 3e1b4ab..d287818 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -354,7 +354,7 @@ config NF_CT_NETLINK_HELPER
 	select NETFILTER_NETLINK
 	depends on NF_CT_NETLINK
 	depends on NETFILTER_NETLINK_QUEUE
-	depends on NETFILTER_NETLINK_QUEUE_CT
+	depends on NETFILTER_NETLINK_GLUE_CT
 	depends on NETFILTER_ADVANCED
 	help
 	  This option enables the user-space connection tracking helpers
@@ -362,10 +362,10 @@ config NF_CT_NETLINK_HELPER
 
 	  If unsure, say `N'.
 
-config NETFILTER_NETLINK_QUEUE_CT
-        bool "NFQUEUE integration with Connection Tracking"
-        default n
-        depends on NETFILTER_NETLINK_QUEUE
+config NETFILTER_NETLINK_GLUE_CT
+	bool "NFQUEUE integration with Connection Tracking"
+	default n
+	depends on NETFILTER_NETLINK_QUEUE && NF_CT_NETLINK
 	help
 	  If this option is enabled, NFQUEUE can include Connection Tracking
 	  information together with the packet is the enqueued via NFNETLINK.
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 704f29b..71d6ada 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2133,7 +2133,7 @@ ctnetlink_alloc_expect(const struct nlattr *const cda[], struct nf_conn *ct,
 		       struct nf_conntrack_tuple *tuple,
 		       struct nf_conntrack_tuple *mask);
 
-#ifdef CONFIG_NETFILTER_NETLINK_QUEUE_CT
+#ifdef CONFIG_NETFILTER_NETLINK_GLUE_CT
 static size_t
 ctnetlink_glue_build_size(const struct nf_conn *ct)
 {
@@ -2403,7 +2403,7 @@ static struct nfnl_ct_hook ctnetlink_glue_hook = {
 	.attach_expect	= ctnetlink_glue_attach_expect,
 	.seq_adjust	= ctnetlink_glue_seqadj,
 };
-#endif /* CONFIG_NETFILTER_NETLINK_QUEUE_CT */
+#endif /* CONFIG_NETFILTER_NETLINK_GLUE_CT */
 
 /***********************************************************************
  * EXPECT
@@ -3387,7 +3387,7 @@ static int __init ctnetlink_init(void)
 		pr_err("ctnetlink_init: cannot register pernet operations\n");
 		goto err_unreg_exp_subsys;
 	}
-#ifdef CONFIG_NETFILTER_NETLINK_QUEUE_CT
+#ifdef CONFIG_NETFILTER_NETLINK_GLUE_CT
 	/* setup interaction between nf_queue and nf_conntrack_netlink. */
 	RCU_INIT_POINTER(nfnl_ct_hook, &ctnetlink_glue_hook);
 #endif
@@ -3408,7 +3408,7 @@ static void __exit ctnetlink_exit(void)
 	unregister_pernet_subsys(&ctnetlink_net_ops);
 	nfnetlink_subsys_unregister(&ctnl_exp_subsys);
 	nfnetlink_subsys_unregister(&ctnl_subsys);
-#ifdef CONFIG_NETFILTER_NETLINK_QUEUE_CT
+#ifdef CONFIG_NETFILTER_NETLINK_GLUE_CT
 	RCU_INIT_POINTER(nfnl_ct_hook, NULL);
 #endif
 }
-- 
2.1.4

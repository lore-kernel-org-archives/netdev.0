From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/35] nfnetlink_cttimeout: add rcu_barrier() on module removal
Date: Sat, 17 Oct 2015 13:32:49 +0200
Message-ID: <1445081590-2924-15-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure kfree_rcu() released objects before leaving the module removal
exit path.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_cttimeout.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 5bda647..c7a2d0e 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -612,6 +612,7 @@ static void __exit cttimeout_exit(void)
 	RCU_INIT_POINTER(nf_ct_timeout_find_get_hook, NULL);
 	RCU_INIT_POINTER(nf_ct_timeout_put_hook, NULL);
 #endif /* CONFIG_NF_CONNTRACK_TIMEOUT */
+	rcu_barrier();
 }
 
 module_init(cttimeout_init);
-- 
2.1.4


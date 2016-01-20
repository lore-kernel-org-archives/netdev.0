From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/6] netfilter: nf_tables_netdev: fix error path in module initialization
Date: Wed, 20 Jan 2016 18:04:03 +0100
Message-ID: <1453309444-2297-6-git-send-email-pablo@netfilter.org>
References: <1453309444-2297-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1453309444-2297-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unregister the chain type and return error, otherwise this leaks the
subscription to the netdevice notifier call chain.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_netdev.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nf_tables_netdev.c b/net/netfilter/nf_tables_netdev.c
index b6605e0..5eefe4a 100644
--- a/net/netfilter/nf_tables_netdev.c
+++ b/net/netfilter/nf_tables_netdev.c
@@ -224,12 +224,12 @@ static int __init nf_tables_netdev_init(void)
 
 	nft_register_chain_type(&nft_filter_chain_netdev);
 	ret = register_pernet_subsys(&nf_tables_netdev_net_ops);
-	if (ret < 0)
+	if (ret < 0) {
 		nft_unregister_chain_type(&nft_filter_chain_netdev);
-
+		return ret;
+	}
 	register_netdevice_notifier(&nf_tables_netdev_notifier);
-
-	return ret;
+	return 0;
 }
 
 static void __exit nf_tables_netdev_exit(void)
-- 
2.1.4


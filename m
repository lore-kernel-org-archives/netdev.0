From: pablo@netfilter.org
Subject: [PATCH 10/10] netfilter: remove unnecessary goto statement for error recovery
Date: Thu, 23 Aug 2012 01:38:46 +0200
Message-ID: <1345678726-3109-11-git-send-email-pablo@netfilter.org>
References: <1345678726-3109-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345678726-3109-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jean Sacren <sakiwit@gmail.com>

Usually it's a good practice to use goto statement for error recovery
when initializing the module. This approach could be an overkill if:

 1) there is only one fail case;
 2) success and failure use the same return statement.

For a cleaner approach, remove the unnecessary goto statement and
directly implement error recovery.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/iptable_filter.c |    6 +-----
 net/ipv4/netfilter/iptable_mangle.c |    6 +-----
 net/ipv4/netfilter/iptable_raw.c    |    6 +-----
 3 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index d20cc37..6b3da5c 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -94,14 +94,10 @@ static int __init iptable_filter_init(void)
 	filter_ops = xt_hook_link(&packet_filter, iptable_filter_hook);
 	if (IS_ERR(filter_ops)) {
 		ret = PTR_ERR(filter_ops);
-		goto cleanup_table;
+		unregister_pernet_subsys(&iptable_filter_net_ops);
 	}
 
 	return ret;
-
- cleanup_table:
-	unregister_pernet_subsys(&iptable_filter_net_ops);
-	return ret;
 }
 
 static void __exit iptable_filter_fini(void)
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index f38b942..85d88f2 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -129,14 +129,10 @@ static int __init iptable_mangle_init(void)
 	mangle_ops = xt_hook_link(&packet_mangler, iptable_mangle_hook);
 	if (IS_ERR(mangle_ops)) {
 		ret = PTR_ERR(mangle_ops);
-		goto cleanup_table;
+		unregister_pernet_subsys(&iptable_mangle_net_ops);
 	}
 
 	return ret;
-
- cleanup_table:
-	unregister_pernet_subsys(&iptable_mangle_net_ops);
-	return ret;
 }
 
 static void __exit iptable_mangle_fini(void)
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index b21e219..03d9696 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -73,14 +73,10 @@ static int __init iptable_raw_init(void)
 	rawtable_ops = xt_hook_link(&packet_raw, iptable_raw_hook);
 	if (IS_ERR(rawtable_ops)) {
 		ret = PTR_ERR(rawtable_ops);
-		goto cleanup_table;
+		unregister_pernet_subsys(&iptable_raw_net_ops);
 	}
 
 	return ret;
-
- cleanup_table:
-	unregister_pernet_subsys(&iptable_raw_net_ops);
-	return ret;
 }
 
 static void __exit iptable_raw_fini(void)
-- 
1.7.10.4


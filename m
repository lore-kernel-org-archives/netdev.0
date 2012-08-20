From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next] ipv4/netfilter: remove unnecessary goto statement for error recovery
Date: Sun, 19 Aug 2012 19:11:32 -0600
Message-ID: <1345425092-11905-1-git-send-email-sakiwit@gmail.com>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Usually it's a good practice to use goto statement for error recovery
when initializing the module. This approach could be an overkill if:

 1) there is only one fail case;
 2) success and failure use the same return statement.

For a cleaner approach, remove the unnecessary goto statement and
directly implement error recovery.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
 net/ipv4/netfilter/iptable_filter.c |    6 +-----
 net/ipv4/netfilter/iptable_mangle.c |    6 +-----
 net/ipv4/netfilter/iptable_raw.c    |    6 +-----
 3 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index 851acec8..9255fd4 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -96,14 +96,10 @@ static int __init iptable_filter_init(void)
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
index aef5d1f..25549c5 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -131,14 +131,10 @@ static int __init iptable_mangle_init(void)
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
index 07fb710..6acf7ca 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -75,14 +75,10 @@ static int __init iptable_raw_init(void)
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

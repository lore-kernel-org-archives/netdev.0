From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 19/19] net: Remove register_net_sysctl_table
Date: Thu, 19 Apr 2012 16:46:06 -0700
Message-ID: <m18vhre14x.fsf@fess.ebiederm.org>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, pablo@netfilter.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:50353 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756050Ab2DSXmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 19:42:05 -0400
In-Reply-To: <m1aa27ia6h.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 19 Apr 2012 16:17:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


All of the users have been converted to use registera_net_sysctl so we
no longer need register_net_sysctl.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/net_namespace.h |    3 ---
 net/sysctl_net.c            |    7 -------
 2 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 6413fcb..3ee4a3d 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -279,7 +279,6 @@ extern void unregister_pernet_subsys(struct pernet_operations *);
 extern int register_pernet_device(struct pernet_operations *);
 extern void unregister_pernet_device(struct pernet_operations *);
 
-struct ctl_path;
 struct ctl_table;
 struct ctl_table_header;
 
@@ -288,8 +287,6 @@ extern int net_sysctl_init(void);
 #else
 static inline int net_sysctl_init(void) { return 0; }
 #endif
-extern struct ctl_table_header *register_net_sysctl_table(struct net *net,
-	const struct ctl_path *path, struct ctl_table *table);
 extern struct ctl_table_header *register_net_sysctl(struct net *net,
 	const char *path, struct ctl_table *table);
 extern void unregister_net_sysctl_table(struct ctl_table_header *header);
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index 2b8d1d9..f3e813a 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -95,13 +95,6 @@ out:
 	return ret;
 }
 
-struct ctl_table_header *register_net_sysctl_table(struct net *net,
-	const struct ctl_path *path, struct ctl_table *table)
-{
-	return __register_sysctl_paths(&net->sysctls, path, table);
-}
-EXPORT_SYMBOL_GPL(register_net_sysctl_table);
-
 struct ctl_table_header *register_net_sysctl(struct net *net,
 	const char *path, struct ctl_table *table)
 {
-- 
1.7.2.5

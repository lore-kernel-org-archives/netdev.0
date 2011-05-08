From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 052/115] sysctl: remove .child from net/ipv4/neigh table
Date: Mon,  9 May 2011 00:39:04 +0200
Message-ID: <1304894407-32201-53-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 net/ipv6/sysctl_net_ipv6.c |   18 +++++++-----------
 1 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 6dcf5e7..a0d9916 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -17,16 +17,6 @@
 
 static struct ctl_table empty[1];
 
-static ctl_table ipv6_static_skeleton[] = {
-	{
-		.procname	= "neigh",
-		.maxlen		= 0,
-		.mode		= 0555,
-		.child		= empty,
-	},
-	{ }
-};
-
 static ctl_table ipv6_table_template[] = {
 	{
 		.procname	= "route",
@@ -160,11 +150,17 @@ void ipv6_sysctl_unregister(void)
 	unregister_pernet_subsys(&ipv6_sysctl_net_ops);
 }
 
+static const struct ctl_path net_ipv6_neigh_path[] = {
+	{ .procname = "net", },
+	{ .procname = "ipv6", },
+	{ .procname = "neigh", },
+	{ },
+};
 static struct ctl_table_header *ip6_base;
 
 int ipv6_static_sysctl_register(void)
 {
-	ip6_base = register_sysctl_paths(net_ipv6_ctl_path, ipv6_static_skeleton);
+	ip6_base = register_sysctl_paths(net_ipv6_neigh_path, empty);
 	if (ip6_base == NULL)
 		return -ENOMEM;
 	return 0;
-- 
1.7.5.134.g1c08b

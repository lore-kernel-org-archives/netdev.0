From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 051/115] sysctl: remove .child from net/ipv4/route and net/ipv4/neigh tables
Date: Mon,  9 May 2011 00:39:03 +0200
Message-ID: <1304894407-32201-52-git-send-email-lucian.grijincu@gmail.com>
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
 net/ipv4/route.c |   15 ++++-----------
 1 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 99e6e4b..46c7b3d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3153,18 +3153,10 @@ static ctl_table ipv4_route_table[] = {
 
 static struct ctl_table empty[1];
 
-static struct ctl_table ipv4_skeleton[] =
-{
-	{ .procname = "route", 
-	  .mode = 0555, .child = ipv4_route_table},
-	{ .procname = "neigh", 
-	  .mode = 0555, .child = empty},
-	{ }
-};
-
-static __net_initdata struct ctl_path ipv4_path[] = {
+static __net_initdata struct ctl_path ipv4_neigh_path[] = {
 	{ .procname = "net", },
 	{ .procname = "ipv4", },
+	{ .procname = "neigh", },
 	{ },
 };
 
@@ -3317,6 +3309,7 @@ int __init ip_rt_init(void)
  */
 void __init ip_static_sysctl_init(void)
 {
-	register_sysctl_paths(ipv4_path, ipv4_skeleton);
+	register_sysctl_paths(ipv4_route_path, ipv4_route_table);
+	register_sysctl_paths(ipv4_neigh_path, empty);
 }
 #endif
-- 
1.7.5.134.g1c08b

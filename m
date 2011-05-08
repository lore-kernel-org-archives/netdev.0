From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 034/115] sysctl: remove .child from sunrpc/svc_rdma
Date: Mon,  9 May 2011 00:38:46 +0200
Message-ID: <1304894407-32201-35-git-send-email-lucian.grijincu@gmail.com>
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
 net/sunrpc/xprtrdma/svc_rdma.c |   26 +++++++-------------------
 1 files changed, 7 insertions(+), 19 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
index 09af4fa..d7c0a70 100644
--- a/net/sunrpc/xprtrdma/svc_rdma.c
+++ b/net/sunrpc/xprtrdma/svc_rdma.c
@@ -118,7 +118,7 @@ static int read_reset_stat(ctl_table *table, int write,
 }
 
 static struct ctl_table_header *svcrdma_table_header;
-static ctl_table svcrdma_parm_table[] = {
+static ctl_table svcrdma_table[] = {
 	{
 		.procname	= "max_requests",
 		.data		= &svcrdma_max_requests,
@@ -213,22 +213,10 @@ static ctl_table svcrdma_parm_table[] = {
 	{ },
 };
 
-static ctl_table svcrdma_table[] = {
-	{
-		.procname	= "svc_rdma",
-		.mode		= 0555,
-		.child		= svcrdma_parm_table
-	},
-	{ },
-};
-
-static ctl_table svcrdma_root_table[] = {
-	{
-		.procname	= "sunrpc",
-		.mode		= 0555,
-		.child		= svcrdma_table
-	},
-	{ },
+static const struct ctl_path svcrdma_path[] = {
+	{ .procname = "sunrpc" },
+	{ .procname = "svc_rdma" },
+	{ }
 };
 
 void svc_rdma_cleanup(void)
@@ -258,8 +246,8 @@ int svc_rdma_init(void)
 		return -ENOMEM;
 
 	if (!svcrdma_table_header)
-		svcrdma_table_header =
-			register_sysctl_table(svcrdma_root_table);
+		svcrdma_table_header = register_sysctl_paths(
+			svcrdma_path, svcrdma_table);
 
 	/* Create the temporary map cache */
 	svc_rdma_map_cachep = kmem_cache_create("svc_rdma_map_cache",
-- 
1.7.5.134.g1c08b

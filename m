From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 036/115] sysctl: remove .child from sunrpc/ (xprtsock)
Date: Mon,  9 May 2011 00:38:48 +0200
Message-ID: <1304894407-32201-37-git-send-email-lucian.grijincu@gmail.com>
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
 net/sunrpc/xprtsock.c |   16 ++++++----------
 1 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index bf005d3..610a2fe 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -59,7 +59,7 @@ static unsigned int xs_tcp_fin_timeout __read_mostly = XS_TCP_LINGER_TO;
 
 /*
  * We can register our own files under /proc/sys/sunrpc by
- * calling register_sysctl_table() again.  The files in that
+ * calling register_sysctl_paths() again.  The files in that
  * directory become the union of all files registered there.
  *
  * We simply need to make sure that we don't collide with
@@ -79,7 +79,7 @@ static struct ctl_table_header *sunrpc_table_header;
  * FIXME: changing the UDP slot table size should also resize the UDP
  *        socket buffers for existing UDP transports
  */
-static ctl_table xs_tunables_table[] = {
+static ctl_table xprtsock_table[] = {
 	{
 		.procname	= "udp_slot_table_entries",
 		.data		= &xprt_udp_slot_table_entries,
@@ -126,13 +126,9 @@ static ctl_table xs_tunables_table[] = {
 	{ },
 };
 
-static ctl_table sunrpc_table[] = {
-	{
-		.procname	= "sunrpc",
-		.mode		= 0555,
-		.child		= xs_tunables_table
-	},
-	{ },
+static const struct ctl_path sunrpc_path[] = {
+	{ .procname = "sunrpc" },
+	{ }
 };
 
 #endif
@@ -2470,7 +2466,7 @@ int init_socket_xprt(void)
 {
 #ifdef RPC_DEBUG
 	if (!sunrpc_table_header)
-		sunrpc_table_header = register_sysctl_table(sunrpc_table);
+		sunrpc_table_header = register_sysctl_paths(sunrpc_path, xprtsock_table);
 #endif
 
 	xprt_register_transport(&xs_udp_transport);
-- 
1.7.5.134.g1c08b

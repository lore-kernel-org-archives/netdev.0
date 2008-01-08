From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 4/6][AX25] Switch to using ctl_paths.
Date: Tue, 08 Jan 2008 19:05:18 +0300
Message-ID: <47839F3E.5080109@openvz.org>
References: <47839C30.2040402@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:53056 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752853AbYAHQFL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2008 11:05:11 -0500
In-Reply-To: <47839C30.2040402@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This one is almost the same as the hunks in the
first patch, but ax25 tables are created dynamically.

So this patch differs a bit to handle this case.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

 net/ax25/sysctl_net_ax25.c |   27 +++++----------------------
 1 files changed, 5 insertions(+), 22 deletions(-)

diff --git a/net/ax25/sysctl_net_ax25.c b/net/ax25/sysctl_net_ax25.c
index 443a836..f597987 100644
--- a/net/ax25/sysctl_net_ax25.c
+++ b/net/ax25/sysctl_net_ax25.c
@@ -31,25 +31,11 @@ static struct ctl_table_header *ax25_table_header;
 static ctl_table *ax25_table;
 static int ax25_table_size;
 
-static ctl_table ax25_dir_table[] = {
-	{
-		.ctl_name	= NET_AX25,
-		.procname	= "ax25",
-		.mode		= 0555,
-	},
-	{ .ctl_name = 0 }
-};
-
-static ctl_table ax25_root_table[] = {
-	{
-		.ctl_name	= CTL_NET,
-		.procname	= "net",
-		.mode		= 0555,
-		.child		= ax25_dir_table
-	},
-	{ .ctl_name = 0 }
+static struct ctl_path ax25_path[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "ax25", .ctl_name = NET_AX25, },
+	{ }
 };
-
 static const ctl_table ax25_param_table[] = {
 	{
 		.ctl_name	= NET_AX25_IP_DEFAULT_MODE,
@@ -243,9 +229,7 @@ void ax25_register_sysctl(void)
 	}
 	spin_unlock_bh(&ax25_dev_lock);
 
-	ax25_dir_table[0].child = ax25_table;
-
-	ax25_table_header = register_sysctl_table(ax25_root_table);
+	ax25_table_header = register_sysctl_paths(ax25_path, ax25_table);
 }
 
 void ax25_unregister_sysctl(void)
@@ -253,7 +237,6 @@ void ax25_unregister_sysctl(void)
 	ctl_table *p;
 	unregister_sysctl_table(ax25_table_header);
 
-	ax25_dir_table[0].child = NULL;
 	for (p = ax25_table; p->ctl_name; p++)
 		kfree(p->child);
 	kfree(ax25_table);


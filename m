From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 3/4 net-2.6.25][UNIX] Use ctl paths to register unix ctl tables
Date: Fri, 30 Nov 2007 19:30:49 +0300
Message-ID: <47503AB9.4080808@openvz.org>
References: <47503919.8060103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:33635 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934246AbXK3QbL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 11:31:11 -0500
In-Reply-To: <47503919.8060103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unlike previous ones, this patch is useful by its own,
as it decreases the vmlinux size :)

But it will be used later, when the per-namespace sysctl
is added.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/unix/sysctl_net_unix.c b/net/unix/sysctl_net_unix.c
index c46cec0..43dd356 100644
--- a/net/unix/sysctl_net_unix.c
+++ b/net/unix/sysctl_net_unix.c
@@ -26,31 +26,17 @@ static ctl_table unix_table[] = {
 	{ .ctl_name = 0 }
 };
 
-static ctl_table unix_net_table[] = {
-	{
-		.ctl_name	= NET_UNIX,
-		.procname	= "unix",
-		.mode		= 0555,
-		.child		= unix_table
-	},
-	{ .ctl_name = 0 }
-};
-
-static ctl_table unix_root_table[] = {
-	{
-		.ctl_name	= CTL_NET,
-		.procname	= "net",
-		.mode		= 0555,
-		.child		= unix_net_table
-	},
-	{ .ctl_name = 0 }
+static struct ctl_path unix_path[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "unix", .ctl_name = NET_UNIX, },
+	{ },
 };
 
 static struct ctl_table_header * unix_sysctl_header;
 
 int unix_sysctl_register(struct net *net)
 {
-	unix_sysctl_header = register_sysctl_table(unix_root_table);
+	unix_sysctl_header = register_sysctl_paths(unix_path, unix_table);
 	return unix_sysctl_header == NULL ? -ENOMEM : 0;
 }
 
-- 
1.5.3.4


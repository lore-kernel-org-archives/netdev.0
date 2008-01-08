From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 1/6][NET] Simple ctl_table to ctl_path conversions.
Date: Tue, 08 Jan 2008 18:54:57 +0300
Message-ID: <47839CD1.4080505@openvz.org>
References: <47839C30.2040402@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:41043 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751156AbYAHPyq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2008 10:54:46 -0500
In-Reply-To: <47839C30.2040402@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch includes many places, that only required
replacing the ctl_table-s with appropriate ctl_paths
and call register_sysctl_paths().

Nothing special was done with them.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

 net/appletalk/sysctl_net_atalk.c |   24 +++++-------------------
 net/bridge/br_netfilter.c        |   24 +++++-------------------
 net/dccp/sysctl.c                |   36 +++++++-----------------------------
 net/ipx/sysctl_net_ipx.c         |   24 +++++-------------------
 net/irda/irsysctl.c              |   28 +++++-----------------------
 net/llc/sysctl_net_llc.c         |   24 +++++-------------------
 net/netrom/sysctl_net_netrom.c   |   24 +++++-------------------
 net/rose/sysctl_net_rose.c       |   24 +++++-------------------
 net/sctp/sysctl.c                |   24 +++++-------------------
 net/x25/sysctl_net_x25.c         |   24 +++++-------------------
 10 files changed, 52 insertions(+), 204 deletions(-)

diff --git a/net/appletalk/sysctl_net_atalk.c b/net/appletalk/sysctl_net_atalk.c
index 7df1778..621805d 100644
--- a/net/appletalk/sysctl_net_atalk.c
+++ b/net/appletalk/sysctl_net_atalk.c
@@ -49,31 +49,17 @@ static struct ctl_table atalk_table[] = {
 	{ 0 },
 };
 
-static struct ctl_table atalk_dir_table[] = {
-	{
-		.ctl_name	= NET_ATALK,
-		.procname	= "appletalk",
-		.mode		= 0555,
-		.child		= atalk_table,
-	},
-	{ 0 },
-};
-
-static struct ctl_table atalk_root_table[] = {
-	{
-		.ctl_name	= CTL_NET,
-		.procname	= "net",
-		.mode		= 0555,
-		.child		= atalk_dir_table,
-	},
-	{ 0 },
+static struct ctl_path atalk_path[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "appletalk", .ctl_name = NET_ATALK, },
+	{ }
 };
 
 static struct ctl_table_header *atalk_table_header;
 
 void atalk_register_sysctl(void)
 {
-	atalk_table_header = register_sysctl_table(atalk_root_table);
+	atalk_table_header = register_sysctl_paths(atalk_path, atalk_table);
 }
 
 void atalk_unregister_sysctl(void)
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 32ac035..91a180a 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -934,24 +934,10 @@ static ctl_table brnf_table[] = {
 	{ .ctl_name = 0 }
 };
 
-static ctl_table brnf_bridge_table[] = {
-	{
-		.ctl_name	= NET_BRIDGE,
-		.procname	= "bridge",
-		.mode		= 0555,
-		.child		= brnf_table,
-	},
-	{ .ctl_name = 0 }
-};
-
-static ctl_table brnf_net_table[] = {
-	{
-		.ctl_name	= CTL_NET,
-		.procname	= "net",
-		.mode		= 0555,
-		.child		= brnf_bridge_table,
-	},
-	{ .ctl_name = 0 }
+static struct ctl_path brnf_path[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "bridge", .ctl_name = NET_BRIDGE, },
+	{ }
 };
 #endif
 
@@ -963,7 +949,7 @@ int __init br_netfilter_init(void)
 	if (ret < 0)
 		return ret;
 #ifdef CONFIG_SYSCTL
-	brnf_sysctl_header = register_sysctl_table(brnf_net_table);
+	brnf_sysctl_header = register_sysctl_paths(brnf_path, brnf_table);
 	if (brnf_sysctl_header == NULL) {
 		printk(KERN_WARNING
 		       "br_netfilter: can't register to sysctl.\n");
diff --git a/net/dccp/sysctl.c b/net/dccp/sysctl.c
index c62c050..2129599 100644
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -100,41 +100,19 @@ static struct ctl_table dccp_default_table[] = {
 	{ .ctl_name = 0, }
 };
 
-static struct ctl_table dccp_table[] = {
-	{
-		.ctl_name	= NET_DCCP_DEFAULT,
-		.procname	= "default",
-		.mode		= 0555,
-		.child		= dccp_default_table,
-	},
-	{ .ctl_name = 0, },
-};
-
-static struct ctl_table dccp_dir_table[] = {
-	{
-		.ctl_name	= NET_DCCP,
-		.procname	= "dccp",
-		.mode		= 0555,
-		.child		= dccp_table,
-	},
-	{ .ctl_name = 0, },
-};
-
-static struct ctl_table dccp_root_table[] = {
-	{
-		.ctl_name	= CTL_NET,
-		.procname	= "net",
-		.mode		= 0555,
-		.child		= dccp_dir_table,
-	},
-	{ .ctl_name = 0, },
+static struct ctl_path dccp_path[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "dccp", .ctl_name = NET_DCCP, },
+	{ .procname = "default", .ctl_name = NET_DCCP_DEFAULT, },
+	{ }
 };
 
 static struct ctl_table_header *dccp_table_header;
 
 int __init dccp_sysctl_init(void)
 {
-	dccp_table_header = register_sysctl_table(dccp_root_table);
+	dccp_table_header = register_sysctl_paths(dccp_path,
+			dccp_default_table);
 
 	return dccp_table_header != NULL ? 0 : -ENOMEM;
 }
diff --git a/net/ipx/sysctl_net_ipx.c b/net/ipx/sysctl_net_ipx.c
index 0cf5264..92fef86 100644
--- a/net/ipx/sysctl_net_ipx.c
+++ b/net/ipx/sysctl_net_ipx.c
@@ -28,31 +28,17 @@ static struct ctl_table ipx_table[] = {
 	{ 0 },
 };
 
-static struct ctl_table ipx_dir_table[] = {
-	{
-		.ctl_name	= NET_IPX,
-		.procname	= "ipx",
-		.mode		= 0555,
-		.child		= ipx_table,
-	},
-	{ 0 },
-};
-
-static struct ctl_table ipx_root_table[] = {
-	{
-		.ctl_name	= CTL_NET,
-		.procname	= "net",
-		.mode		= 0555,
-		.child		= ipx_dir_table,
-	},
-	{ 0 },
+static struct ctl_path ipx_path[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "ipx", .ctl_name = NET_IPX, },
+	{ }
 };
 
 static struct ctl_table_header *ipx_table_header;
 
 void ipx_register_sysctl(void)
 {
-	ipx_table_header = register_sysctl_table(ipx_root_table);
+	ipx_table_header = register_sysctl_paths(ipx_path, ipx_table);
 }
 
 void ipx_unregister_sysctl(void)
diff --git a/net/irda/irsysctl.c b/net/irda/irsysctl.c
index 565cbf0..d8aba86 100644
--- a/net/irda/irsysctl.c
+++ b/net/irda/irsysctl.c
@@ -234,28 +234,10 @@ static ctl_table irda_table[] = {
 	{ .ctl_name = 0 }
 };
 
-/* One directory */
-static ctl_table irda_net_table[] = {
-	{
-		.ctl_name	= NET_IRDA,
-		.procname	= "irda",
-		.maxlen		= 0,
-		.mode		= 0555,
-		.child		= irda_table
-	},
-	{ .ctl_name = 0 }
-};
-
-/* The parent directory */
-static ctl_table irda_root_table[] = {
-	{
-		.ctl_name	= CTL_NET,
-		.procname	= "net",
-		.maxlen		= 0,
-		.mode		= 0555,
-		.child		= irda_net_table
-	},
-	{ .ctl_name = 0 }
+static struct ctl_path irda_path[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "irda", .ctl_name = NET_IRDA, },
+	{ }
 };
 
 static struct ctl_table_header *irda_table_header;
@@ -268,7 +250,7 @@ static struct ctl_table_header *irda_table_header;
  */
 int __init irda_sysctl_register(void)
 {
-	irda_table_header = register_sysctl_table(irda_root_table);
+	irda_table_header = register_sysctl_paths(irda_path, irda_table);
 	if (!irda_table_header)
 		return -ENOMEM;
 
diff --git a/net/llc/sysctl_net_llc.c b/net/llc/sysctl_net_llc.c
index 46992d0..5bef1dc 100644
--- a/net/llc/sysctl_net_llc.c
+++ b/net/llc/sysctl_net_llc.c
@@ -92,31 +92,17 @@ static struct ctl_table llc_table[] = {
 	{ 0 },
 };
 
-static struct ctl_table llc_dir_table[] = {
-	{
-		.ctl_name	= NET_LLC,
-		.procname	= "llc",
-		.mode		= 0555,
-		.child		= llc_table,
-	},
-	{ 0 },
-};
-
-static struct ctl_table llc_root_table[] = {
-	{
-		.ctl_name	= CTL_NET,
-		.procname	= "net",
-		.mode		= 0555,
-		.child		= llc_dir_table,
-	},
-	{ 0 },
+static struct ctl_path llc_path[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "llc", .ctl_name = NET_LLC, },
+	{ }
 };
 
 static struct ctl_table_header *llc_table_header;
 
 int __init llc_sysctl_init(void)
 {
-	llc_table_header = register_sysctl_table(llc_root_table);
+	llc_table_header = register_sysctl_paths(llc_path, llc_table);
 
 	return llc_table_header ? 0 : -ENOMEM;
 }
diff --git a/net/netrom/sysctl_net_netrom.c b/net/netrom/sysctl_net_netrom.c
index 2ea68da..34c96c9 100644
--- a/net/netrom/sysctl_net_netrom.c
+++ b/net/netrom/sysctl_net_netrom.c
@@ -170,29 +170,15 @@ static ctl_table nr_table[] = {
 	{ .ctl_name = 0 }
 };
 
-static ctl_table nr_dir_table[] = {
-	{
-		.ctl_name	= NET_NETROM,
-		.procname	= "netrom",
-		.mode		= 0555,
-		.child		= nr_table
-	},
-	{ .ctl_name = 0 }
-};
-
-static ctl_table nr_root_table[] = {
-	{
-		.ctl_name	= CTL_NET,
-		.procname	= "net",
-		.mode		= 0555,
-		.child		= nr_dir_table
-	},
-	{ .ctl_name = 0 }
+static struct ctl_path nr_path[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "netrom", .ctl_name = NET_NETROM, },
+	{ }
 };
 
 void __init nr_register_sysctl(void)
 {
-	nr_table_header = register_sysctl_table(nr_root_table);
+	nr_table_header = register_sysctl_paths(nr_path, nr_table);
 }
 
 void nr_unregister_sysctl(void)
diff --git a/net/rose/sysctl_net_rose.c b/net/rose/sysctl_net_rose.c
index 455b055..20be348 100644
--- a/net/rose/sysctl_net_rose.c
+++ b/net/rose/sysctl_net_rose.c
@@ -138,29 +138,15 @@ static ctl_table rose_table[] = {
 	{ .ctl_name = 0 }
 };
 
-static ctl_table rose_dir_table[] = {
-	{
-		.ctl_name	= NET_ROSE,
-		.procname	= "rose",
-		.mode		= 0555,
-		.child		= rose_table
-	},
-	{ .ctl_name = 0 }
-};
-
-static ctl_table rose_root_table[] = {
-	{
-		.ctl_name	= CTL_NET,
-		.procname	= "net",
-		.mode		= 0555,
-		.child		= rose_dir_table
-	},
-	{ .ctl_name = 0 }
+static struct ctl_path rose_path[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "rose", .ctl_name = NET_ROSE, },
+	{ }
 };
 
 void __init rose_register_sysctl(void)
 {
-	rose_table_header = register_sysctl_table(rose_root_table);
+	rose_table_header = register_sysctl_paths(rose_path, rose_table);
 }
 
 void rose_unregister_sysctl(void)
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index da4f157..5eb6ea8 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -275,24 +275,10 @@ static ctl_table sctp_table[] = {
 	{ .ctl_name = 0 }
 };
 
-static ctl_table sctp_net_table[] = {
-	{
-		.ctl_name	= NET_SCTP,
-		.procname	= "sctp",
-		.mode		= 0555,
-		.child		= sctp_table
-	},
-	{ .ctl_name = 0 }
-};
-
-static ctl_table sctp_root_table[] = {
-	{
-		.ctl_name	= CTL_NET,
-		.procname	= "net",
-		.mode		= 0555,
-		.child		= sctp_net_table
-	},
-	{ .ctl_name = 0 }
+static struct ctl_path sctp_path[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "sctp", .ctl_name = NET_SCTP, },
+	{ }
 };
 
 static struct ctl_table_header * sctp_sysctl_header;
@@ -300,7 +286,7 @@ static struct ctl_table_header * sctp_sysctl_header;
 /* Sysctl registration.  */
 void sctp_sysctl_register(void)
 {
-	sctp_sysctl_header = register_sysctl_table(sctp_root_table);
+	sctp_sysctl_header = register_sysctl_paths(sctp_path, sctp_table);
 }
 
 /* Sysctl deregistration.  */
diff --git a/net/x25/sysctl_net_x25.c b/net/x25/sysctl_net_x25.c
index a59b77f..6ebda25 100644
--- a/net/x25/sysctl_net_x25.c
+++ b/net/x25/sysctl_net_x25.c
@@ -84,29 +84,15 @@ static struct ctl_table x25_table[] = {
 	{ 0, },
 };
 
-static struct ctl_table x25_dir_table[] = {
-	{
-		.ctl_name =	NET_X25,
-		.procname =	"x25",
-		.mode =		0555,
-		.child =	x25_table,
-	},
-	{ 0, },
-};
-
-static struct ctl_table x25_root_table[] = {
-	{
-		.ctl_name =	CTL_NET,
-		.procname =	"net",
-		.mode =		0555,
-		.child =	x25_dir_table,
-	},
-	{ 0, },
+static struct ctl_path x25_path[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "x25", .ctl_name = NET_X25, },
+	{ }
 };
 
 void __init x25_register_sysctl(void)
 {
-	x25_table_header = register_sysctl_table(x25_root_table);
+	x25_table_header = register_sysctl_paths(x25_path, x25_table);
 }
 
 void x25_unregister_sysctl(void)


From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 4/4] Don't use seq_release_private where inappropriate.
Date: Fri, 29 Feb 2008 16:50:28 +0300
Message-ID: <47C80DA4.9000208@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:44967 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751922AbYB2Nub (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 08:50:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some netfilter code and rxrpc one use seq_open() to open
a proc file, but seq_release_private to release one.

This is harmless, but ambiguous.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index 089252e..9668c3a 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -379,7 +379,7 @@ static const struct file_operations ct_cpu_seq_fops = {
 	.open    = ct_cpu_seq_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release_private,
+	.release = seq_release,
 };
 
 int __init nf_conntrack_ipv4_compat_init(void)
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index e88e96a..a9bf6e4 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -293,7 +293,7 @@ static const struct file_operations ct_cpu_seq_fops = {
 	.open	 = ct_cpu_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = seq_release_private,
+	.release = seq_release,
 };
 #endif /* CONFIG_PROC_FS */
 
diff --git a/net/rxrpc/ar-proc.c b/net/rxrpc/ar-proc.c
index 83eda24..017322e 100644
--- a/net/rxrpc/ar-proc.c
+++ b/net/rxrpc/ar-proc.c
@@ -103,7 +103,7 @@ const struct file_operations rxrpc_call_seq_fops = {
 	.open		= rxrpc_call_seq_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
-	.release	= seq_release_private,
+	.release	= seq_release,
 };
 
 /*
@@ -188,5 +188,5 @@ const struct file_operations rxrpc_connection_seq_fops = {
 	.open		= rxrpc_connection_seq_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
-	.release	= seq_release_private,
+	.release	= seq_release,
 };


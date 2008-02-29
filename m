From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 3/4] Use seq_open_private in appletalk and decnet.
Date: Fri, 29 Feb 2008 16:48:24 +0300
Message-ID: <47C80D28.9020009@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Christine Caulfield <christine.caulfield@googlemail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:44538 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758522AbYB2Nsj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 08:48:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two also perform manual seq_open_private, so patch them both
at once. But unlike ATM code, these already use the seq_release_private, 
so I splitted this patch from the previous one.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/appletalk/aarp.c b/net/appletalk/aarp.c
index 18058bb..61166f6 100644
--- a/net/appletalk/aarp.c
+++ b/net/appletalk/aarp.c
@@ -1033,25 +1033,8 @@ static const struct seq_operations aarp_seq_ops = {
 
 static int aarp_seq_open(struct inode *inode, struct file *file)
 {
-	struct seq_file *seq;
-	int rc = -ENOMEM;
-	struct aarp_iter_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
-
-	if (!s)
-		goto out;
-
-	rc = seq_open(file, &aarp_seq_ops);
-	if (rc)
-		goto out_kfree;
-
-	seq	     = file->private_data;
-	seq->private = s;
-	memset(s, 0, sizeof(*s));
-out:
-	return rc;
-out_kfree:
-	kfree(s);
-	goto out;
+	return seq_open_private(file, &aarp_seq_ops,
+			sizeof(struct aarp_iter_state));
 }
 
 const struct file_operations atalk_seq_arp_fops = {

diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index acd48ee..23fd95a 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -2320,25 +2320,8 @@ static const struct seq_operations dn_socket_seq_ops = {
 
 static int dn_socket_seq_open(struct inode *inode, struct file *file)
 {
-	struct seq_file *seq;
-	int rc = -ENOMEM;
-	struct dn_iter_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
-
-	if (!s)
-		goto out;
-
-	rc = seq_open(file, &dn_socket_seq_ops);
-	if (rc)
-		goto out_kfree;
-
-	seq		= file->private_data;
-	seq->private	= s;
-	memset(s, 0, sizeof(*s));
-out:
-	return rc;
-out_kfree:
-	kfree(s);
-	goto out;
+	return seq_open_private(file, &dn_socket_seq_ops,
+			sizeof(struct dn_iter_state));
 }
 
 static const struct file_operations dn_socket_seq_fops = {


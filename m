From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 4/6][NET-2.6.24] Make decnet code use the seq_open_private()
Date: Tue, 09 Oct 2007 19:59:38 +0400
Message-ID: <470BA56A.6020903@openvz.org>
References: <470BA351.3070208@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	patrick@tykepenguin.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:49813 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756718AbXJIQCr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 12:02:47 -0400
In-Reply-To: <470BA351.3070208@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just switch to the consolidated code.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Cc: Patrick Caulfield <patrick@tykepenguin.com>

---

diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index b66e3be..e851b14 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -580,24 +580,8 @@ static const struct seq_operations dn_ne
 
 static int dn_neigh_seq_open(struct inode *inode, struct file *file)
 {
-	struct seq_file *seq;
-	int rc = -ENOMEM;
-	struct neigh_seq_state *s = kzalloc(sizeof(*s), GFP_KERNEL);
-
-	if (!s)
-		goto out;
-
-	rc = seq_open(file, &dn_neigh_seq_ops);
-	if (rc)
-		goto out_kfree;
-
-	seq          = file->private_data;
-	seq->private = s;
-out:
-	return rc;
-out_kfree:
-	kfree(s);
-	goto out;
+	return seq_open_private(file, &dn_neigh_seq_ops,
+			sizeof(struct neigh_seq_state));
 }
 
 static const struct file_operations dn_neigh_seq_fops = {
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index b7ebf99..97eee5e 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1739,23 +1739,8 @@ static const struct seq_operations dn_rt
 
 static int dn_rt_cache_seq_open(struct inode *inode, struct file *file)
 {
-	struct seq_file *seq;
-	int rc = -ENOMEM;
-	struct dn_rt_cache_iter_state *s;
-
-	s = kzalloc(sizeof(*s), GFP_KERNEL);
-	if (!s)
-		goto out;
-	rc = seq_open(file, &dn_rt_cache_seq_ops);
-	if (rc)
-		goto out_kfree;
-	seq		= file->private_data;
-	seq->private	= s;
-out:
-	return rc;
-out_kfree:
-	kfree(s);
-	goto out;
+	return seq_open_private(file, &dn_rt_cache_seq_ops,
+			sizeof(struct dn_rt_cache_iter_state));
 }
 
 static const struct file_operations dn_rt_cache_seq_fops = {


From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 5/6][NET-2.6.24] Make the IRDA use the seq_open_private()
Date: Tue, 09 Oct 2007 20:01:32 +0400
Message-ID: <470BA5DC.8060905@openvz.org>
References: <470BA351.3070208@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	samuel@sortiz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:43795 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754609AbXJIQGg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 12:06:36 -0400
In-Reply-To: <470BA351.3070208@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just switch to the consolidated code

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Cc: Samuel Ortiz <samuel@sortiz.org>

---

diff --git a/net/irda/irlap.c b/net/irda/irlap.c
index 3d76aaf..f3236ac 100644
--- a/net/irda/irlap.c
+++ b/net/irda/irlap.c
@@ -1219,29 +1219,11 @@ static const struct seq_operations irlap
 
 static int irlap_seq_open(struct inode *inode, struct file *file)
 {
-	struct seq_file *seq;
-	int rc = -ENOMEM;
-	struct irlap_iter_state *s = kzalloc(sizeof(*s), GFP_KERNEL);
+	if (irlap == NULL)
+		return -EINVAL;
 
-	if (!s)
-		goto out;
-
-	if (irlap == NULL) {
-		rc = -EINVAL;
-		goto out_kfree;
-	}
-
-	rc = seq_open(file, &irlap_seq_ops);
-	if (rc)
-		goto out_kfree;
-
-	seq	     = file->private_data;
-	seq->private = s;
-out:
-	return rc;
-out_kfree:
-	kfree(s);
-	goto out;
+	return seq_open_private(file, &irlap_seq_ops,
+			sizeof(struct irlap_iter_state));
 }
 
 const struct file_operations irlap_seq_fops = {
diff --git a/net/irda/irlmp.c b/net/irda/irlmp.c
index 7efa930..7db92ce 100644
--- a/net/irda/irlmp.c
+++ b/net/irda/irlmp.c
@@ -2003,27 +2003,10 @@ static const struct seq_operations irlmp
 
 static int irlmp_seq_open(struct inode *inode, struct file *file)
 {
-	struct seq_file *seq;
-	int rc = -ENOMEM;
-	struct irlmp_iter_state *s;
-
 	IRDA_ASSERT(irlmp != NULL, return -EINVAL;);
 
-	s = kmalloc(sizeof(*s), GFP_KERNEL);
-	if (!s)
-		goto out;
-
-	rc = seq_open(file, &irlmp_seq_ops);
-	if (rc)
-		goto out_kfree;
-
-	seq	     = file->private_data;
-	seq->private = s;
-out:
-	return rc;
-out_kfree:
-	kfree(s);
-	goto out;
+	return seq_open_private(file, &irlmp_seq_ops,
+			sizeof(struct irlmp_iter_state));
 }
 
 const struct file_operations irlmp_seq_fops = {
diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index 3d7ab03..1311976 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -1884,25 +1884,8 @@ static const struct seq_operations irttp
 
 static int irttp_seq_open(struct inode *inode, struct file *file)
 {
-	struct seq_file *seq;
-	int rc = -ENOMEM;
-	struct irttp_iter_state *s;
-
-	s = kzalloc(sizeof(*s), GFP_KERNEL);
-	if (!s)
-		goto out;
-
-	rc = seq_open(file, &irttp_seq_ops);
-	if (rc)
-		goto out_kfree;
-
-	seq	     = file->private_data;
-	seq->private = s;
-out:
-	return rc;
-out_kfree:
-	kfree(s);
-	goto out;
+	return seq_open_private(file, &irttp_seq_ops,
+			sizeof(struct irttp_iter_state));
 }
 
 const struct file_operations irttp_seq_fops = {


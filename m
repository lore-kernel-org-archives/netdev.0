From: Joe Perches <joe@perches.com>
Subject: [PATCH 14/20] net/atm/proc.c: checkpatch cleanups
Date: Mon,  7 Dec 2009 21:57:10 -0800
Message-ID: <1535bc772cc6eaa5dd62dfc7752baf0e8854402c.1260251570.git.joe@perches.com>
References: <cover.1260251570.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1058 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932638AbZLHF5O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2009 00:57:14 -0500
In-Reply-To: <cover.1260251570.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Includes some or all of these:

Mostly 80 column wrapped.
printk->pr_info and pr_cont
Use print_hex_dump
Use __func__ for embedded print strings
Move embedded assigns out of tests
Move trailing statements to new lines
switch/case cleanups
    removed breaks after returns
Removed paren around returns
Use %pM
Moved leading continuation logical tests to end of previous line

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/proc.c |   81 ++++++++++++++++++++++++++++++-------------------------
 1 files changed, 44 insertions(+), 37 deletions(-)

diff --git a/net/atm/proc.c b/net/atm/proc.c
index ab8419a..476779d 100644
--- a/net/atm/proc.c
+++ b/net/atm/proc.c
@@ -24,15 +24,15 @@
 #include <linux/init.h> /* for __init */
 #include <net/net_namespace.h>
 #include <net/atmclip.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
+#include <linux/param.h> /* for HZ */
 #include <asm/atomic.h>
-#include <asm/param.h> /* for HZ */
 #include "resources.h"
 #include "common.h" /* atm_proc_init prototype */
 #include "signaling.h" /* to get sigd - ugly too */
 
-static ssize_t proc_dev_atm_read(struct file *file,char __user *buf,size_t count,
-    loff_t *pos);
+static ssize_t proc_dev_atm_read(struct file *file, char __user *buf,
+				 size_t count, loff_t *pos);
 
 static const struct file_operations proc_atm_dev_ops = {
 	.owner =	THIS_MODULE,
@@ -43,9 +43,9 @@ static void add_stats(struct seq_file *seq, const char *aal,
   const struct k_atm_aal_stats *stats)
 {
 	seq_printf(seq, "%s ( %d %d %d %d %d )", aal,
-	    atomic_read(&stats->tx),atomic_read(&stats->tx_err),
-	    atomic_read(&stats->rx),atomic_read(&stats->rx_err),
-	    atomic_read(&stats->rx_drop));
+		   atomic_read(&stats->tx), atomic_read(&stats->tx_err),
+		   atomic_read(&stats->rx), atomic_read(&stats->rx_err),
+		   atomic_read(&stats->rx_drop));
 }
 
 static void atm_dev_info(struct seq_file *seq, const struct atm_dev *dev)
@@ -151,8 +151,8 @@ static void *vcc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 static void pvc_info(struct seq_file *seq, struct atm_vcc *vcc)
 {
-	static const char *const class_name[] =
-		{"off","UBR","CBR","VBR","ABR"};
+	static const char *const class_name[] = {
+		"off", "UBR", "CBR", "VBR", "ABR"};
 	static const char *const aal_name[] = {
 		"---",	"1",	"2",	"3/4",	/*  0- 3 */
 		"???",	"5",	"???",	"???",	/*  4- 7 */
@@ -160,11 +160,12 @@ static void pvc_info(struct seq_file *seq, struct atm_vcc *vcc)
 		"???",	"0",	"???",	"???"};	/* 12-15 */
 
 	seq_printf(seq, "%3d %3d %5d %-3s %7d %-5s %7d %-6s",
-	    vcc->dev->number,vcc->vpi,vcc->vci,
-	    vcc->qos.aal >= ARRAY_SIZE(aal_name) ? "err" :
-	    aal_name[vcc->qos.aal],vcc->qos.rxtp.min_pcr,
-	    class_name[vcc->qos.rxtp.traffic_class],vcc->qos.txtp.min_pcr,
-	    class_name[vcc->qos.txtp.traffic_class]);
+		   vcc->dev->number, vcc->vpi, vcc->vci,
+		   vcc->qos.aal >= ARRAY_SIZE(aal_name) ? "err" :
+		   aal_name[vcc->qos.aal], vcc->qos.rxtp.min_pcr,
+		   class_name[vcc->qos.rxtp.traffic_class],
+		   vcc->qos.txtp.min_pcr,
+		   class_name[vcc->qos.txtp.traffic_class]);
 	if (test_bit(ATM_VF_IS_CLIP, &vcc->flags)) {
 		struct clip_vcc *clip_vcc = CLIP_VCC(vcc);
 		struct net_device *dev;
@@ -195,19 +196,20 @@ static void vcc_info(struct seq_file *seq, struct atm_vcc *vcc)
 		seq_printf(seq, "%3d %3d %5d ", vcc->dev->number, vcc->vpi,
 			vcc->vci);
 	switch (sk->sk_family) {
-		case AF_ATMPVC:
-			seq_printf(seq, "PVC");
-			break;
-		case AF_ATMSVC:
-			seq_printf(seq, "SVC");
-			break;
-		default:
-			seq_printf(seq, "%3d", sk->sk_family);
+	case AF_ATMPVC:
+		seq_printf(seq, "PVC");
+		break;
+	case AF_ATMSVC:
+		seq_printf(seq, "SVC");
+		break;
+	default:
+		seq_printf(seq, "%3d", sk->sk_family);
 	}
-	seq_printf(seq, " %04lx  %5d %7d/%7d %7d/%7d [%d]\n", vcc->flags, sk->sk_err,
-		  sk_wmem_alloc_get(sk), sk->sk_sndbuf,
-		  sk_rmem_alloc_get(sk), sk->sk_rcvbuf,
-		  atomic_read(&sk->sk_refcnt));
+	seq_printf(seq, " %04lx  %5d %7d/%7d %7d/%7d [%d]\n",
+		   vcc->flags, sk->sk_err,
+		   sk_wmem_alloc_get(sk), sk->sk_sndbuf,
+		   sk_rmem_alloc_get(sk), sk->sk_rcvbuf,
+		   atomic_read(&sk->sk_refcnt));
 }
 
 static void svc_info(struct seq_file *seq, struct atm_vcc *vcc)
@@ -376,32 +378,35 @@ static ssize_t proc_dev_atm_read(struct file *file, char __user *buf,
 	unsigned long page;
 	int length;
 
-	if (count == 0) return 0;
+	if (count == 0)
+		return 0;
 	page = get_zeroed_page(GFP_KERNEL);
-	if (!page) return -ENOMEM;
+	if (!page)
+		return -ENOMEM;
 	dev = PDE(file->f_path.dentry->d_inode)->data;
 	if (!dev->ops->proc_read)
 		length = -EINVAL;
 	else {
-		length = dev->ops->proc_read(dev,pos,(char *) page);
-		if (length > count) length = -EINVAL;
+		length = dev->ops->proc_read(dev, pos, (char *)page);
+		if (length > count)
+			length = -EINVAL;
 	}
 	if (length >= 0) {
-		if (copy_to_user(buf,(char *) page,length)) length = -EFAULT;
+		if (copy_to_user(buf, (char *)page, length))
+			length = -EFAULT;
 		(*pos)++;
 	}
 	free_page(page);
 	return length;
 }
 
-
 struct proc_dir_entry *atm_proc_root;
 EXPORT_SYMBOL(atm_proc_root);
 
 
 int atm_proc_dev_register(struct atm_dev *dev)
 {
-	int digits,num;
+	int digits, num;
 	int error;
 
 	/* No proc info */
@@ -410,26 +415,28 @@ int atm_proc_dev_register(struct atm_dev *dev)
 
 	error = -ENOMEM;
 	digits = 0;
-	for (num = dev->number; num; num /= 10) digits++;
-	if (!digits) digits++;
+	for (num = dev->number; num; num /= 10)
+		digits++;
+	if (!digits)
+		digits++;
 
 	dev->proc_name = kmalloc(strlen(dev->type) + digits + 2, GFP_KERNEL);
 	if (!dev->proc_name)
 		goto err_out;
-	sprintf(dev->proc_name,"%s:%d",dev->type, dev->number);
+	sprintf(dev->proc_name, "%s:%d", dev->type, dev->number);
 
 	dev->proc_entry = proc_create_data(dev->proc_name, 0, atm_proc_root,
 					   &proc_atm_dev_ops, dev);
 	if (!dev->proc_entry)
 		goto err_free_name;
 	return 0;
+
 err_free_name:
 	kfree(dev->proc_name);
 err_out:
 	return error;
 }
 
-
 void atm_proc_dev_deregister(struct atm_dev *dev)
 {
 	if (!dev->ops->proc_read)
-- 
1.6.6.rc0.57.gad7a


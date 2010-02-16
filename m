From: Patrick McHardy <kaber@trash.net>
Subject: netfiltr 21/62: ipt_CLUSTERIP: simplify seq_file codeA
Date: Tue, 16 Feb 2010 15:55:48 +0100 (MET)
Message-ID: <20100216145546.2796.36908.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 477781477a88f60c89003c852def4aedc6f78101
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Fri Jan 22 22:21:18 2010 +0100

    netfiltr: ipt_CLUSTERIP: simplify seq_file codeA
    
    Pass "struct clusterip_config" itself to seq_file iterators
    and save one dereference. Proc entry itself isn't interesting.
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 40ca2d2..0886f96 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -560,8 +560,7 @@ struct clusterip_seq_position {
 
 static void *clusterip_seq_start(struct seq_file *s, loff_t *pos)
 {
-	const struct proc_dir_entry *pde = s->private;
-	struct clusterip_config *c = pde->data;
+	struct clusterip_config *c = s->private;
 	unsigned int weight;
 	u_int32_t local_nodes;
 	struct clusterip_seq_position *idx;
@@ -632,10 +631,9 @@ static int clusterip_proc_open(struct inode *inode, struct file *file)
 
 	if (!ret) {
 		struct seq_file *sf = file->private_data;
-		struct proc_dir_entry *pde = PDE(inode);
-		struct clusterip_config *c = pde->data;
+		struct clusterip_config *c = PDE(inode)->data;
 
-		sf->private = pde;
+		sf->private = c;
 
 		clusterip_config_get(c);
 	}
@@ -645,8 +643,7 @@ static int clusterip_proc_open(struct inode *inode, struct file *file)
 
 static int clusterip_proc_release(struct inode *inode, struct file *file)
 {
-	struct proc_dir_entry *pde = PDE(inode);
-	struct clusterip_config *c = pde->data;
+	struct clusterip_config *c = PDE(inode)->data;
 	int ret;
 
 	ret = seq_release(inode, file);
@@ -660,10 +657,9 @@ static int clusterip_proc_release(struct inode *inode, struct file *file)
 static ssize_t clusterip_proc_write(struct file *file, const char __user *input,
 				size_t size, loff_t *ofs)
 {
+	struct clusterip_config *c = PDE(file->f_path.dentry->d_inode)->data;
 #define PROC_WRITELEN	10
 	char buffer[PROC_WRITELEN+1];
-	const struct proc_dir_entry *pde = PDE(file->f_path.dentry->d_inode);
-	struct clusterip_config *c = pde->data;
 	unsigned long nodenum;
 
 	if (copy_from_user(buffer, input, PROC_WRITELEN))

From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 13/62: xt_hashlimit: simplify seqfile code
Date: Tue, 16 Feb 2010 15:55:37 +0100 (MET)
Message-ID: <20100216145535.2796.20117.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit a1004d8e3d463012f231bab104325ecb15637f78
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Mon Jan 18 08:14:50 2010 +0100

    netfilter: xt_hashlimit: simplify seqfile code
    
    Simply pass hashtable to seqfile iterators, proc entry itself is not needed.
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 5bdc1fb..944fd11 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -841,8 +841,7 @@ static struct xt_match hashlimit_mt_reg[] __read_mostly = {
 static void *dl_seq_start(struct seq_file *s, loff_t *pos)
 	__acquires(htable->lock)
 {
-	struct proc_dir_entry *pde = s->private;
-	struct xt_hashlimit_htable *htable = pde->data;
+	struct xt_hashlimit_htable *htable = s->private;
 	unsigned int *bucket;
 
 	spin_lock_bh(&htable->lock);
@@ -859,8 +858,7 @@ static void *dl_seq_start(struct seq_file *s, loff_t *pos)
 
 static void *dl_seq_next(struct seq_file *s, void *v, loff_t *pos)
 {
-	struct proc_dir_entry *pde = s->private;
-	struct xt_hashlimit_htable *htable = pde->data;
+	struct xt_hashlimit_htable *htable = s->private;
 	unsigned int *bucket = (unsigned int *)v;
 
 	*pos = ++(*bucket);
@@ -874,8 +872,7 @@ static void *dl_seq_next(struct seq_file *s, void *v, loff_t *pos)
 static void dl_seq_stop(struct seq_file *s, void *v)
 	__releases(htable->lock)
 {
-	struct proc_dir_entry *pde = s->private;
-	struct xt_hashlimit_htable *htable = pde->data;
+	struct xt_hashlimit_htable *htable = s->private;
 	unsigned int *bucket = (unsigned int *)v;
 
 	kfree(bucket);
@@ -917,8 +914,7 @@ static int dl_seq_real_show(struct dsthash_ent *ent, u_int8_t family,
 
 static int dl_seq_show(struct seq_file *s, void *v)
 {
-	struct proc_dir_entry *pde = s->private;
-	struct xt_hashlimit_htable *htable = pde->data;
+	struct xt_hashlimit_htable *htable = s->private;
 	unsigned int *bucket = (unsigned int *)v;
 	struct dsthash_ent *ent;
 	struct hlist_node *pos;
@@ -944,7 +940,7 @@ static int dl_proc_open(struct inode *inode, struct file *file)
 
 	if (!ret) {
 		struct seq_file *sf = file->private_data;
-		sf->private = PDE(inode);
+		sf->private = PDE(inode)->data;
 	}
 	return ret;
 }

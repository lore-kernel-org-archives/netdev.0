From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] neigh: simplify seq_file code
Date: Fri, 22 Jan 2010 22:16:05 +0200
Message-ID: <20100122201605.GB22342@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:60523 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488Ab0AVUQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 15:16:13 -0500
Received: by fxm20 with SMTP id 20so1737369fxm.21
        for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 12:16:08 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simpily pass 'struct neigh_table' with seq_file private pointer,
and save one dereference. Proc entry itself isn't interesting.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/core/neighbour.c |   11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2417,8 +2417,7 @@ EXPORT_SYMBOL(neigh_seq_stop);
 
 static void *neigh_stat_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	struct proc_dir_entry *pde = seq->private;
-	struct neigh_table *tbl = pde->data;
+	struct neigh_table *tbl = seq->private;
 	int cpu;
 
 	if (*pos == 0)
@@ -2435,8 +2434,7 @@ static void *neigh_stat_seq_start(struct seq_file *seq, loff_t *pos)
 
 static void *neigh_stat_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct proc_dir_entry *pde = seq->private;
-	struct neigh_table *tbl = pde->data;
+	struct neigh_table *tbl = seq->private;
 	int cpu;
 
 	for (cpu = *pos; cpu < nr_cpu_ids; ++cpu) {
@@ -2455,8 +2453,7 @@ static void neigh_stat_seq_stop(struct seq_file *seq, void *v)
 
 static int neigh_stat_seq_show(struct seq_file *seq, void *v)
 {
-	struct proc_dir_entry *pde = seq->private;
-	struct neigh_table *tbl = pde->data;
+	struct neigh_table *tbl = seq->private;
 	struct neigh_statistics *st = v;
 
 	if (v == SEQ_START_TOKEN) {
@@ -2501,7 +2498,7 @@ static int neigh_stat_seq_open(struct inode *inode, struct file *file)
 
 	if (!ret) {
 		struct seq_file *sf = file->private_data;
-		sf->private = PDE(inode);
+		sf->private = PDE(inode)->data;
 	}
 	return ret;
 };

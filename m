From: Joe Perches <joe@perches.com>
Subject: [PATCH] 2.6.0-test5 SEQ_START_TOKEN drivers/net/* [1/3]
Date: Tue, 09 Sep 2003 16:06:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063148794.603.70.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: torvalds@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-hams@vger.kernel.org, paulus@samba.org,
   mostrows@styx.uwaterloo.ca
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -urN linux-2.6.0-test5/drivers/net/hamradio/bpqether.c SEQ_START_TOKEN_5/drivers/net/hamradio/bpqether.c
--- linux-2.6.0-test5/drivers/net/hamradio/bpqether.c	2003-09-08 12:50:03.000000000 -0700
+++ SEQ_START_TOKEN_5/drivers/net/hamradio/bpqether.c	2003-09-09 11:38:37.000000000 -0700
@@ -389,8 +389,6 @@
 	return buf;
 }
 
-#define BPQ_PROC_START ((void *)1)
-
 static void *bpq_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	int i = 1;
@@ -399,7 +397,7 @@
 	rcu_read_lock();
 
 	if (*pos == 0)
-		return BPQ_PROC_START;
+		return SEQ_START_TOKEN;
 	
 	list_for_each_entry(bpqdev, &bpq_devices, bpq_list) {
 		if (i == *pos)
@@ -414,7 +412,7 @@
 
 	++*pos;
 
-	if (v == BPQ_PROC_START)
+	if (v == SEQ_START_TOKEN)
 		p = bpq_devices.next;
 	else
 		p = ((struct bpqdev *)v)->bpq_list.next;
@@ -431,7 +429,7 @@
 
 static int bpq_seq_show(struct seq_file *seq, void *v)
 {
-	if (v == BPQ_PROC_START)
+	if (v == SEQ_START_TOKEN)
 		seq_puts(seq, 
 			 "dev   ether      destination        accept from\n");
 	else {
diff -urN linux-2.6.0-test5/drivers/net/pppoe.c SEQ_START_TOKEN_5/drivers/net/pppoe.c
--- linux-2.6.0-test5/drivers/net/pppoe.c	2003-09-08 12:50:08.000000000 -0700
+++ SEQ_START_TOKEN_5/drivers/net/pppoe.c	2003-09-08 18:35:35.000000000 -0700
@@ -986,7 +986,7 @@
 	struct pppox_opt *po;
 	char *dev_name;
 
-	if (v == (void *)1) {
+	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq, "Id       Address              Device\n");
 		goto out;
 	}
@@ -1025,7 +1025,7 @@
 	loff_t l = *pos;
 
 	read_lock_bh(&pppoe_hash_lock);
-	return l ? pppoe_get_idx(--l) : (void *)1;
+	return l ? pppoe_get_idx(--l) : SEQ_START_TOKEN;
 }
 
 static void *pppoe_seq_next(struct seq_file *seq, void *v, loff_t *pos)
@@ -1033,7 +1033,7 @@
 	struct pppox_opt *po;
 
 	++*pos;
-	if (v == (void *)1) {
+	if (v == SEQ_START_TOKEN) {
 		po = pppoe_get_idx(0);
 		goto out;
 	}
diff -urN linux-2.6.0-test5/drivers/net/wireless/strip.c SEQ_START_TOKEN_5/drivers/net/wireless/strip.c
--- linux-2.6.0-test5/drivers/net/wireless/strip.c	2003-09-08 12:50:17.000000000 -0700
+++ SEQ_START_TOKEN_5/drivers/net/wireless/strip.c	2003-09-09 11:39:31.000000000 -0700
@@ -965,8 +965,6 @@
 	return (buffer);
 }
 
-#define STRIP_PROC_HEADER	((void *)1)
-
 /* get Nth element of the linked list */
 static struct strip *strip_get_idx(loff_t pos) 
 {
@@ -984,7 +982,7 @@
 static void *strip_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	rcu_read_lock();
-	return *pos ? strip_get_idx(*pos - 1) : STRIP_PROC_HEADER;
+	return *pos ? strip_get_idx(*pos - 1) : SEQ_START_TOKEN;
 }
 
 static void *strip_seq_next(struct seq_file *seq, void *v, loff_t *pos)
@@ -993,7 +991,7 @@
 	struct strip *s;
 
 	++*pos;
-	if (v == STRIP_PROC_HEADER)
+	if (v == SEQ_START_TOKEN)
 		return strip_get_idx(1);
 
 	s = v;
@@ -1149,7 +1147,7 @@
  */
 static int strip_seq_show(struct seq_file *seq, void *v)
 {
-	if (v == STRIP_PROC_HEADER)
+	if (v == SEQ_START_TOKEN)
 		seq_printf(seq, "strip_version: %s\n", StripVersion);
 	else
 		strip_seq_status_info(seq, (const struct strip *)v);

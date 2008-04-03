From: Joe Perches <joe@perches.com>
Subject: [PATCH net 2.6.26] net/atm - Use SEQ_START_TOKEN
Date: Wed, 02 Apr 2008 18:29:29 -0700
Message-ID: <1207186169.23161.275.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David S Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:1241 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1754683AbYDCB3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 21:29:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>

 net/atm/lec.c       |    8 ++++----
 net/atm/proc.c      |   16 ++++++++--------
 net/atm/resources.c |    5 +++--
 3 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index aa3785e..9bd64bd 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -1014,7 +1014,7 @@ static void *lec_tbl_walk(struct lec_state *state, struct hlist_head *tbl,
 
 	if (!e)
 		e = tbl->first;
-	if (e == (void *)1) {
+	if (e == SEQ_START_TOKEN) {
 		e = tbl->first;
 		--*l;
 	}
@@ -1116,9 +1116,9 @@ static void *lec_seq_start(struct seq_file *seq, loff_t *pos)
 	state->locked = NULL;
 	state->arp_table = 0;
 	state->misc_table = 0;
-	state->node = (void *)1;
+	state->node = SEQ_START_TOKEN;
 
-	return *pos ? lec_get_idx(state, *pos) : (void *)1;
+	return *pos ? lec_get_idx(state, *pos) : SEQ_START_TOKEN;
 }
 
 static void lec_seq_stop(struct seq_file *seq, void *v)
@@ -1147,7 +1147,7 @@ static int lec_seq_show(struct seq_file *seq, void *v)
 	    "                          Status            Flags "
 	    "VPI/VCI Recv VPI/VCI\n";
 
-	if (v == (void *)1)
+	if (v == SEQ_START_TOKEN)
 		seq_puts(seq, lec_banner);
 	else {
 		struct lec_state *state = seq->private;
diff --git a/net/atm/proc.c b/net/atm/proc.c
index b995b66..5c9f3d1 100644
--- a/net/atm/proc.c
+++ b/net/atm/proc.c
@@ -78,7 +78,7 @@ static int __vcc_walk(struct sock **sock, int family, int *bucket, loff_t l)
 {
 	struct sock *sk = *sock;
 
-	if (sk == (void *)1) {
+	if (sk == SEQ_START_TOKEN) {
 		for (*bucket = 0; *bucket < VCC_HTABLE_SIZE; ++*bucket) {
 			struct hlist_head *head = &vcc_hash[*bucket];
 
@@ -98,7 +98,7 @@ try_again:
 		sk = sk_head(&vcc_hash[*bucket]);
 		goto try_again;
 	}
-	sk = (void *)1;
+	sk = SEQ_START_TOKEN;
 out:
 	*sock = sk;
 	return (l < 0);
@@ -130,8 +130,8 @@ static void *vcc_seq_start(struct seq_file *seq, loff_t *pos)
 	loff_t left = *pos;
 
 	read_lock(&vcc_sklist_lock);
-	state->sk = (void *)1;
-	return left ? vcc_walk(state, left) : (void *)1;
+	state->sk = SEQ_START_TOKEN;
+	return left ? vcc_walk(state, left) : SEQ_START_TOKEN;
 }
 
 static void vcc_seq_stop(struct seq_file *seq, void *v)
@@ -235,7 +235,7 @@ static int atm_dev_seq_show(struct seq_file *seq, void *v)
 		"Itf Type    ESI/\"MAC\"addr "
 		"AAL(TX,err,RX,err,drop) ...               [refcnt]\n";
 
-	if (v == (void *)1)
+	if (v == SEQ_START_TOKEN)
 		seq_puts(seq, atm_dev_banner);
 	else {
 		struct atm_dev *dev = list_entry(v, struct atm_dev, dev_list);
@@ -269,7 +269,7 @@ static int pvc_seq_show(struct seq_file *seq, void *v)
 	static char atm_pvc_banner[] =
 		"Itf VPI VCI   AAL RX(PCR,Class) TX(PCR,Class)\n";
 
-	if (v == (void *)1)
+	if (v == SEQ_START_TOKEN)
 		seq_puts(seq, atm_pvc_banner);
 	else {
 		struct vcc_state *state = seq->private;
@@ -301,7 +301,7 @@ static const struct file_operations pvc_seq_fops = {
 
 static int vcc_seq_show(struct seq_file *seq, void *v)
 {
-	if (v == (void *)1) {
+	if (v == SEQ_START_TOKEN) {
 		seq_printf(seq, sizeof(void *) == 4 ? "%-8s%s" : "%-16s%s",
 			"Address ", "Itf VPI VCI   Fam Flags Reply "
 			"Send buffer     Recv buffer      [refcnt]\n");
@@ -338,7 +338,7 @@ static int svc_seq_show(struct seq_file *seq, void *v)
 	static char atm_svc_banner[] =
 		"Itf VPI VCI           State      Remote\n";
 
-	if (v == (void *)1)
+	if (v == SEQ_START_TOKEN)
 		seq_puts(seq, atm_svc_banner);
 	else {
 		struct vcc_state *state = seq->private;
diff --git a/net/atm/resources.c b/net/atm/resources.c
index 1bcf6dc..a34ba94 100644
--- a/net/atm/resources.c
+++ b/net/atm/resources.c
@@ -415,7 +415,7 @@ static __inline__ void *dev_get_idx(loff_t left)
 void *atm_dev_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	mutex_lock(&atm_dev_mutex);
-	return *pos ? dev_get_idx(*pos) : (void *) 1;
+	return *pos ? dev_get_idx(*pos) : SEQ_START_TOKEN;
 }
 
 void atm_dev_seq_stop(struct seq_file *seq, void *v)
@@ -426,7 +426,8 @@ void atm_dev_seq_stop(struct seq_file *seq, void *v)
 void *atm_dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	++*pos;
-	v = (v == (void *)1) ? atm_devs.next : ((struct list_head *)v)->next;
+	v = (v == SEQ_START_TOKEN)
+		? atm_devs.next : ((struct list_head *)v)->next;
 	return (v == &atm_devs) ? NULL : v;
 }
 



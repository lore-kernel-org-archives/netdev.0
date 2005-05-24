From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net/802/tr.c: s/struct rif_cache_s/struct rif_cache/
Date: Tue, 24 May 2005 21:48:03 +0400
Message-ID: <200505242148.03588.adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"_s" suffix is certainly of hungarian origin.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

--- linux-sparse-001/net/802/tr.c	2005-05-24 19:08:47.000000000 +0400
+++ linux-s/net/802/tr.c	2005-05-24 21:42:33.000000000 +0400
@@ -47,12 +47,12 @@ static void rif_check_expire(unsigned lo
  *	Each RIF entry we learn is kept this way
  */
  
-struct rif_cache_s {	
+struct rif_cache {
 	unsigned char addr[TR_ALEN];
 	int iface;
 	__be16 rcf;
 	__be16 rseg[8];
-	struct rif_cache_s *next;
+	struct rif_cache *next;
 	unsigned long last_used;
 	unsigned char local_ring;
 };
@@ -64,7 +64,7 @@ struct rif_cache_s {	
  *	up a lot.
  */
  
-static struct rif_cache_s *rif_table[RIF_TABLE_SIZE];
+static struct rif_cache *rif_table[RIF_TABLE_SIZE];
 
 static DEFINE_SPINLOCK(rif_lock);
 
@@ -249,7 +249,7 @@ void tr_source_route(struct sk_buff *skb
 {
 	int slack;
 	unsigned int hash;
-	struct rif_cache_s *entry;
+	struct rif_cache *entry;
 	unsigned char *olddata;
 	static const unsigned char mcast_func_addr[] 
 		= {0xC0,0x00,0x00,0x04,0x00,0x00};
@@ -337,7 +337,7 @@ printk("source routing for %02X:%02X:%02
 static void tr_add_rif_info(struct trh_hdr *trh, struct net_device *dev)
 {
 	unsigned int hash, rii_p = 0;
-	struct rif_cache_s *entry;
+	struct rif_cache *entry;
 
 
 	spin_lock_bh(&rif_lock);
@@ -373,7 +373,7 @@ printk("adding rif_entry: addr:%02X:%02X
 		 *	FIXME: We ought to keep some kind of cache size
 		 *	limiting and adjust the timers to suit.
 		 */
-		entry=kmalloc(sizeof(struct rif_cache_s),GFP_ATOMIC);
+		entry=kmalloc(sizeof(struct rif_cache),GFP_ATOMIC);
 
 		if(!entry) 
 		{
@@ -435,7 +435,7 @@ static void rif_check_expire(unsigned lo
 	spin_lock_bh(&rif_lock);
 	
 	for(i =0; i < RIF_TABLE_SIZE; i++) {
-		struct rif_cache_s *entry, **pentry;
+		struct rif_cache *entry, **pentry;
 		
 		pentry = rif_table+i;
 		while((entry=*pentry) != NULL) {
@@ -467,10 +467,10 @@ static void rif_check_expire(unsigned lo
  
 #ifdef CONFIG_PROC_FS
 
-static struct rif_cache_s *rif_get_idx(loff_t pos)
+static struct rif_cache *rif_get_idx(loff_t pos)
 {
 	int i;
-	struct rif_cache_s *entry;
+	struct rif_cache *entry;
 	loff_t off = 0;
 
 	for(i = 0; i < RIF_TABLE_SIZE; i++) 
@@ -493,7 +493,7 @@ static void *rif_seq_start(struct seq_fi
 static void *rif_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	int i;
-	struct rif_cache_s *ent = v;
+	struct rif_cache *ent = v;
 
 	++*pos;
 
@@ -522,7 +522,7 @@ static void rif_seq_stop(struct seq_file
 static int rif_seq_show(struct seq_file *seq, void *v)
 {
 	int j, rcf_len, segment, brdgnmb;
-	struct rif_cache_s *entry = v;
+	struct rif_cache *entry = v;
 
 	if (v == SEQ_START_TOKEN)
 		seq_puts(seq,

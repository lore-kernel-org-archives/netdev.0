From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/6) tr - get rid of typedef
Date: Wed, 20 Aug 2003 17:08:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030820170800.66f882e7.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-tr@linuxtr.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Get rid of the egregious typedef in 802/tr code.
This type of pointer aliasing is confusing and gross.

Patch against 2.6.0-test3 bk latest.


diff -Nru a/net/802/tr.c b/net/802/tr.c
--- a/net/802/tr.c	Wed Aug 20 15:51:13 2003
+++ b/net/802/tr.c	Wed Aug 20 15:51:13 2003
@@ -42,8 +42,6 @@
 
 #define TR_SR_DEBUG 0
 
-typedef struct rif_cache_s *rif_cache;
-
 /*
  *	Each RIF entry we learn is kept this way
  */
@@ -53,7 +51,7 @@
 	int iface;
 	__u16 rcf;
 	__u16 rseg[8];
-	rif_cache next;
+	struct rif_cache_s *next;
 	unsigned long last_used;
 	unsigned char local_ring;
 };
@@ -65,7 +63,7 @@
  *	up a lot.
  */
  
-static rif_cache rif_table[RIF_TABLE_SIZE];
+static struct rif_cache_s *rif_table[RIF_TABLE_SIZE];
 
 static spinlock_t rif_lock = SPIN_LOCK_UNLOCKED;
 
@@ -235,7 +233,7 @@
 {
 	int i, slack;
 	unsigned int hash;
-	rif_cache entry;
+	struct rif_cache_s *entry;
 	unsigned char *olddata;
 	unsigned char mcast_func_addr[] = {0xC0,0x00,0x00,0x04,0x00,0x00};
 	unsigned long flags ; 
@@ -325,7 +323,7 @@
 {
 	int i;
 	unsigned int hash, rii_p = 0;
-	rif_cache entry;
+	struct rif_cache_s *entry;
 
 
 	spin_lock_bh(&rif_lock);
@@ -426,7 +424,7 @@
 	
 	for(i=0; i < RIF_TABLE_SIZE;i++) 
 	{
-		rif_cache entry, *pentry=rif_table+i;	
+		struct rif_cache_s *entry, **pentry=rif_table+i;	
 		while((entry=*pentry)) 
 		{
 			/*
@@ -501,7 +499,7 @@
 static int rif_seq_show(struct seq_file *seq, void *v)
 {
 	int j, rcf_len, segment, brdgnmb;
-	rif_cache entry = v;
+	struct rif_cache_s *entry = v;
 
 	if (v == RIF_PROC_START)
 		seq_puts(seq,

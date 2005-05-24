From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] tokenring: be'ify trh_hdr, trllc, rif_cache_s
Date: Tue, 24 May 2005 21:46:53 +0400
Message-ID: <200505242146.53270.adobriyan@gmail.com>
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

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

--- linux-sparse-000/include/linux/if_tr.h	2005-05-24 08:49:03.000000000 +0400
+++ linux-sparse-001/include/linux/if_tr.h	2005-05-24 18:57:09.000000000 +0400
@@ -36,8 +36,8 @@ struct trh_hdr {
 	__u8  fc;			/* frame control field */
 	__u8  daddr[TR_ALEN];		/* destination address */
 	__u8  saddr[TR_ALEN];		/* source address */
-	__u16 rcf;			/* route control field */
-	__u16 rseg[8];			/* routing registers */
+	__be16 rcf;			/* route control field */
+	__be16 rseg[8];			/* routing registers */
 };
 
 #ifdef __KERNEL__
@@ -55,7 +55,7 @@ struct trllc {
 	__u8  ssap;			/* source SAP */
 	__u8  llc;			/* LLC control field */
 	__u8  protid[3];		/* protocol id */
-	__u16 ethertype;		/* ether type field */
+	__be16 ethertype;		/* ether type field */
 };
 
 /* Token-Ring statistics collection data. */
--- linux-sparse-000/net/802/tr.c	2005-05-24 08:49:20.000000000 +0400
+++ linux-sparse-001/net/802/tr.c	2005-05-24 19:06:12.000000000 +0400
@@ -50,8 +50,8 @@ static void rif_check_expire(unsigned lo
 struct rif_cache_s {	
 	unsigned char addr[TR_ALEN];
 	int iface;
-	__u16 rcf;
-	__u16 rseg[8];
+	__be16 rcf;
+	__be16 rseg[8];
 	struct rif_cache_s *next;
 	unsigned long last_used;
 	unsigned char local_ring;

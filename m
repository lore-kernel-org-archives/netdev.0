From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] ATM: CLIP: C99 initializers
Date: Thu, 03 Jul 2003 18:38:50 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030703.183850.78164037.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-atm-general@lists.sourceforge.net,
   yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, jmorris@intercode.com.au, chas@cmf.nrl.navy.mil
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

This converts nlip_tbl to C99 initializers.
(and fixes wrong value for proxy_len and locktime.)

Thanks.

Index: linux-2.5/net/atm/clip.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/atm/clip.c,v
retrieving revision 1.17
diff -u -r1.17 clip.c
--- linux-2.5/net/atm/clip.c	23 Jun 2003 22:08:56 -0000	1.17
+++ linux-2.5/net/atm/clip.c	3 Jul 2003 08:17:44 -0000
@@ -327,40 +327,34 @@
 	return hash_val;
 }
 
-
 static struct neigh_table clip_tbl = {
-	NULL,			/* next */
-	AF_INET,		/* family */
-	sizeof(struct neighbour)+sizeof(struct atmarp_entry), /* entry_size */
-	4,			/* key_len */
-	clip_hash,
-	clip_constructor,	/* constructor */
-	NULL,			/* pconstructor */
-	NULL,			/* pdestructor */
-	NULL,			/* proxy_redo */
-	"clip_arp_cache",
-	{			/* neigh_parms */
-		NULL,		/* next */
-		NULL,		/* neigh_setup */
-		&clip_tbl,	/* tbl */
-		0,		/* entries */
-		NULL,		/* priv */
-		NULL,		/* sysctl_table */
-		30*HZ,		/* base_reachable_time */
-		1*HZ,		/* retrans_time */
-		60*HZ,		/* gc_staletime */
-		30*HZ,		/* reachable_time */
-		5*HZ,		/* delay_probe_time */
-		3,		/* queue_len */
-		3,		/* ucast_probes */
-		0,		/* app_probes */
-		3,		/* mcast_probes */
-		1*HZ,		/* anycast_delay */
-		(8*HZ)/10,	/* proxy_delay */
-		1*HZ,		/* proxy_qlen */
-		64		/* locktime */
+	.family 	= AF_INET,
+	.entry_size 	= sizeof(struct neighbour)+sizeof(struct atmarp_entry),
+	.key_len 	= 4,
+	.hash 		= clip_hash,
+	.constructor 	= clip_constructor,
+	.id 		= "clip_arp_cache",
+
+	/* parameters are copied from ARP ... */
+	.parms = {
+		.tbl 			= &clip_tbl,
+		.base_reachable_time 	= 30 * HZ,
+		.retrans_time 		= 1 * HZ,
+		.gc_staletime 		= 60 * HZ,
+		.reachable_time 	= 30 * HZ,
+		.delay_probe_time 	= 5 * HZ,
+		.queue_len 		= 3,
+		.ucast_probes 		= 3,
+		.mcast_probes 		= 3,
+		.anycast_delay 		= 1 * HZ,
+		.proxy_delay 		= (8 * HZ) / 10,
+		.proxy_qlen 		= 64,
+		.locktime 		= 1 * HZ,
 	},
-	30*HZ,128,512,1024	/* copied from ARP ... */
+	.gc_interval 	= 30 * HZ,
+	.gc_thresh1 	= 128,
+	.gc_thresh2 	= 512,
+	.gc_thresh3 	= 1024,
 };
 
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] more DECLARE_MUTEX() in headers crap
Date: Mon, 5 Jul 2004 12:53:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705105317.GA30269@lst.de>
References: <20040620112328.GB13691@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Content-Disposition: inline
In-Reply-To: <20040620112328.GB13691@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jun 20, 2004 at 01:23:28PM +0200, Christoph Hellwig wrote:
> okay, the gunk we had in arp_tables is in ip6_tables and ip6_tables,
> too.  In fact those three files seem to be 80% copy & paste of each
> other..

ping


--- 1.8/include/linux/netfilter_ipv4/ip_tables.h	2004-06-19 20:55:10 +02:00
+++ edited/include/linux/netfilter_ipv4/ip_tables.h	2004-06-20 10:25:40 +02:00
@@ -284,8 +284,6 @@
 	struct ipt_entry entrytable[0];
 };
 
-extern struct semaphore ipt_mutex;
-
 /* Standard return verdict, or do jump. */
 #define IPT_STANDARD_TARGET ""
 /* Error verdict. */
@@ -338,7 +336,6 @@
  *	Main firewall chains definitions and global var's definitions.
  */
 #ifdef __KERNEL__
-static DECLARE_MUTEX(ipt_mutex);
 
 #include <linux/init.h>
 extern void ipt_init(void) __init;
===== include/linux/netfilter_ipv6/ip6_tables.h 1.7 vs edited =====
--- 1.7/include/linux/netfilter_ipv6/ip6_tables.h	2004-06-19 20:55:10 +02:00
+++ edited/include/linux/netfilter_ipv6/ip6_tables.h	2004-06-20 10:26:32 +02:00
@@ -107,10 +107,6 @@
 	u_int64_t pcnt, bcnt;			/* Packet and byte counters */
 };
 
-#ifdef __KERNEL__
-static DECLARE_MUTEX(ip6t_mutex);
-#endif
-
 /* Values for "flag" field in struct ip6t_ip6 (general ip6 structure). */
 #define IP6T_F_PROTO		0x01	/* Set if rule cares about upper 
 					   protocols */
===== net/ipv4/netfilter/ip_tables.c 1.24 vs edited =====
--- 1.24/net/ipv4/netfilter/ip_tables.c	2004-06-07 05:15:04 +02:00
+++ edited/net/ipv4/netfilter/ip_tables.c	2004-06-20 12:29:17 +02:00
@@ -61,6 +61,8 @@
 #endif
 #define SMP_ALIGN(x) (((x) + SMP_CACHE_BYTES-1) & ~(SMP_CACHE_BYTES-1))
 
+static DECLARE_MUTEX(ipt_mutex);
+
 /* Must have mutex */
 #define ASSERT_READ_LOCK(x) IP_NF_ASSERT(down_trylock(&ipt_mutex) != 0)
 #define ASSERT_WRITE_LOCK(x) IP_NF_ASSERT(down_trylock(&ipt_mutex) != 0)
===== net/ipv6/netfilter/ip6_tables.c 1.29 vs edited =====
--- 1.29/net/ipv6/netfilter/ip6_tables.c	2004-06-07 05:15:04 +02:00
+++ edited/net/ipv6/netfilter/ip6_tables.c	2004-06-20 12:29:29 +02:00
@@ -66,6 +66,7 @@
 #endif
 #define SMP_ALIGN(x) (((x) + SMP_CACHE_BYTES-1) & ~(SMP_CACHE_BYTES-1))
 
+static DECLARE_MUTEX(ip6t_mutex);
 
 /* Must have mutex */
 #define ASSERT_READ_LOCK(x) IP_NF_ASSERT(down_trylock(&ip6t_mutex) != 0)

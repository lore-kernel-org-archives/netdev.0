From: Andreas Maier <andi@cosy.sbg.ac.at>
Subject: Hide AF_INET
Date: Thu, 04 Nov 2004 13:13:10 +0000
Message-ID: <1099573990l.4491l.1l@leu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; DelSp=Yes; Format=Flowed
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I need a Linux testbed to test applications in an IPv6-only  
environment. Unfortunately IPv6 cannot be enabled without also enabling  
IPv4. Therefor I try to hide AF_INET from user space with the appended  
patch.

It is a partial success in that AF_INET is no longer available to user  
space, the kernel does not crash, TCP6 connections (ssh) work and UDP6  
connections seem to work (DNS).

The drawback is that ICMP6 (ping6) does not work and that I think my  
basic approach is ugly.

What could be a quick hack to get ICMP6 working in my scenario?

Would it be possible - with reasonable effort - to convert networking  
code so that IPv6 no longer depends on IPv4 so that an IPv6-only  
configuration can be created easily?

Thanks for your help,
-andi


--- net/ipv4/af_inet.c.orig	2004-10-29 15:01:42.000000000 +0200
+++ net/ipv4/af_inet.c	2004-11-04 11:57:11.000000000 +0100
@@ -1032,7 +1032,10 @@
 	 *	Tell SOCKET that we are alive...
 	 */

+#define HIDE_V4
+#ifndef HIDE_V4
   	(void)sock_register(&inet_family_ops);
+#endif

 	/*
 	 *	Add all the base protocols.
@@ -1066,9 +1069,11 @@
   	 *	Set the IP module up
   	 */

+#ifndef HIDE_V4
 	ip_init();

 	tcp_v4_init(&inet_family_ops);
+#endif

 	/* Setup TCP slab cache for open requests. */
 	tcp_init();
@@ -1078,7 +1083,9 @@
 	 *	Set the ICMP layer up
 	 */

+#ifndef HIDE_V4
 	icmp_init(&inet_family_ops);
+#endif

 	/*
 	 *	Initialise the multicast router
@@ -1093,7 +1100,9 @@
 	if(init_ipv4_mibs())
 		printk(KERN_CRIT "inet_init: Cannot init ipv4 mibs\n"); ;
 	
+#ifndef HIDE_V4
 	ipv4_proc_init();
+#endif

 	ipfrag_init();

-- 
| Andreas Maier               Paris-Lodron University of Salzburg   |
| (andi [at] cosy.sbg.ac.at)  Department of Scientific Computing    |
| Tel. +43/662/8044-6339      Jakob Haringerstr. 2                  |
| Fax. +43/662/8044-172       5020 Salzburg / Austria, Europe       |

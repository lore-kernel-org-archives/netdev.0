From: Daniel McNeil <daniel@osdl.org>
Subject: [PATCH 2.5.69] net/ipv6 missing kmem_cache_destroy in module exit
Date: 13 May 2003 15:26:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1052864772.2442.8.camel@ibm-c.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ywQdVU7VcCa55jELU9BG"
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
   jmorris@intercode.com.au
Return-path: <netdev-bounce@oss.sgi.com>
To: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-ywQdVU7VcCa55jELU9BG
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

ipv6 is missing the calls to kmem_cache_destory() in module_exit
and some cleanup routines.

-- 
Daniel McNeil <daniel@osdl.org>

--=-ywQdVU7VcCa55jELU9BG
Content-Disposition: attachment; filename=patch.2.5.69-ipv6.kmem
Content-Type: text/x-patch; name=patch.2.5.69-ipv6.kmem; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

diff -rupN -X /home/daniel/dontdiff linux-2.5.69/net/ipv6/af_inet6.c linux-2.5.69-ipv6/net/ipv6/af_inet6.c
--- linux-2.5.69/net/ipv6/af_inet6.c	Sun May  4 16:53:32 2003
+++ linux-2.5.69-ipv6/net/ipv6/af_inet6.c	Tue May 13 11:33:41 2003
@@ -867,6 +867,9 @@ static void inet6_exit(void)
 	ipv6_sysctl_unregister();	
 #endif
 	cleanup_ipv6_mibs();
+	kmem_cache_destroy(tcp6_sk_cachep);
+	kmem_cache_destroy(udp6_sk_cachep);
+	kmem_cache_destroy(raw6_sk_cachep);
 }
 module_exit(inet6_exit);
 #endif /* MODULE */
diff -rupN -X /home/daniel/dontdiff linux-2.5.69/net/ipv6/ip6_fib.c linux-2.5.69-ipv6/net/ipv6/ip6_fib.c
--- linux-2.5.69/net/ipv6/ip6_fib.c	Sun May  4 16:53:37 2003
+++ linux-2.5.69-ipv6/net/ipv6/ip6_fib.c	Tue May 13 11:33:41 2003
@@ -1241,6 +1241,8 @@ void __init fib6_init(void)
 void fib6_gc_cleanup(void)
 {
 	del_timer(&ip6_fib_timer);
+	if (fib6_node_kmem)
+		kmem_cache_destroy(fib6_node_kmem);
 }
 #endif
 
diff -rupN -X /home/daniel/dontdiff linux-2.5.69/net/ipv6/route.c linux-2.5.69-ipv6/net/ipv6/route.c
--- linux-2.5.69/net/ipv6/route.c	Sun May  4 16:53:36 2003
+++ linux-2.5.69-ipv6/net/ipv6/route.c	Tue May 13 11:33:41 2003
@@ -1899,5 +1899,6 @@ void ip6_route_cleanup(void)
 	xfrm6_fini();
 	rt6_ifdown(NULL);
 	fib6_gc_cleanup();
+	kmem_cache_destroy(ip6_dst_ops.kmem_cachep);
 }
 #endif	/* MODULE */

--=-ywQdVU7VcCa55jELU9BG--

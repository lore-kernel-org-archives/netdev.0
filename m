From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] ipv6 route: handle kmem_cache_create() failure
Date: Mon, 23 Feb 2004 13:37:11 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040223133711.11bf677a.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
Please apply to 2.6.3-current.


From: <WHarms@bfs.de>(Walter Harms)



 linux-263-kj1-rddunlap/net/ipv6/route.c |    3 +++
 1 files changed, 3 insertions(+)

diff -puN net/ipv6/route.c~ipv6_route_kmemcc net/ipv6/route.c
--- linux-263-kj1/net/ipv6/route.c~ipv6_route_kmemcc	2004-02-18 14:41:42.000000000 -0800
+++ linux-263-kj1-rddunlap/net/ipv6/route.c	2004-02-18 14:41:42.000000000 -0800
@@ -1987,6 +1987,9 @@ void __init ip6_route_init(void)
 						     sizeof(struct rt6_info),
 						     0, SLAB_HWCACHE_ALIGN,
 						     NULL, NULL);
+	if (!ip6_dst_ops.kmem_cachep)
+		panic("cannot create ip6_dst_cache");
+
 	fib6_init();
 #ifdef 	CONFIG_PROC_FS
 	p = proc_net_create("ipv6_route", 0, rt6_proc_info);

_


--
~Randy

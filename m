From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] ipv6 fib: handle kmem_cache_create() failure
Date: Mon, 23 Feb 2004 13:37:02 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040223133702.34ba5b05.rddunlap@osdl.org>
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



 linux-263-kj1-rddunlap/net/ipv6/ip6_fib.c |    2 ++
 1 files changed, 2 insertions(+)

diff -puN net/ipv6/ip6_fib.c~ipv6_fib_kmemcc net/ipv6/ip6_fib.c
--- linux-263-kj1/net/ipv6/ip6_fib.c~ipv6_fib_kmemcc	2004-02-18 14:41:32.000000000 -0800
+++ linux-263-kj1-rddunlap/net/ipv6/ip6_fib.c	2004-02-18 14:41:32.000000000 -0800
@@ -1239,6 +1239,8 @@ void __init fib6_init(void)
 					   sizeof(struct fib6_node),
 					   0, SLAB_HWCACHE_ALIGN,
 					   NULL, NULL);
+	if (!fib6_node_kmem)
+		panic("cannot create fib6_nodes cache");
 }
 
 #ifdef MODULE

_


--
~Randy

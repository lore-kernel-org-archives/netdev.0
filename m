From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] neighbour: handle kmem_cache_create() failure
Date: Mon, 23 Feb 2004 13:34:02 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040223133402.1e722f6f.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


hi,
Please apply to 2.6.3-current.

--
~Randy


From: <WHarms@bfs.de>(Walter Harms)


 linux-263-kj1-rddunlap/net/core/neighbour.c |    4 ++++
 1 files changed, 4 insertions(+)

diff -puN net/core/neighbour.c~net_neighbour_kmemcc net/core/neighbour.c
--- linux-263-kj1/net/core/neighbour.c~net_neighbour_kmemcc	2004-02-18 14:45:21.000000000 -0800
+++ linux-263-kj1-rddunlap/net/core/neighbour.c	2004-02-18 14:45:21.000000000 -0800
@@ -1168,6 +1168,10 @@ void neigh_table_init(struct neigh_table
 						      15) & ~15,
 						     0, SLAB_HWCACHE_ALIGN,
 						     NULL, NULL);
+
+	if (!tbl->kmem_cachep)
+		panic("cannot create neighbour cache");
+
 	tbl->lock	       = RW_LOCK_UNLOCKED;
 	init_timer(&tbl->gc_timer);
 	tbl->gc_timer.data     = (unsigned long)tbl;

_

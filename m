From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] ipv4 ipmr: handle kmem_cache_create() failure
Date: Mon, 23 Feb 2004 13:36:51 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040223133651.75c85ea2.rddunlap@osdl.org>
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




 linux-263-kj1-rddunlap/net/ipv4/ipmr.c |    3 +++
 1 files changed, 3 insertions(+)

diff -puN net/ipv4/ipmr.c~ipv4_ipmr_kmemcc net/ipv4/ipmr.c
--- linux-263-kj1/net/ipv4/ipmr.c~ipv4_ipmr_kmemcc	2004-02-18 14:41:20.000000000 -0800
+++ linux-263-kj1-rddunlap/net/ipv4/ipmr.c	2004-02-18 14:41:20.000000000 -0800
@@ -1892,6 +1892,9 @@ void __init ip_mr_init(void)
 				       sizeof(struct mfc_cache),
 				       0, SLAB_HWCACHE_ALIGN,
 				       NULL, NULL);
+	if (!mrt_cachep)
+		panic("cannot allocate ip_mrt_cache");
+
 	init_timer(&ipmr_expire_timer);
 	ipmr_expire_timer.function=ipmr_expire_process;
 	register_netdevice_notifier(&ip_mr_notifier);

_


--
~Randy

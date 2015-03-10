From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] tipc: fix undefined
	__ipv6_sock_mc_join compile error
Date: Tue, 10 Mar 2015 10:08:52 +0800
Message-ID: <1425953333-31403-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, kbuild-all@01.org,
	fengguang.wu@intel.com
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

When CONFIG_IPV6 option is disabled, below compile error appears while
building TIPC module:

ERROR: "__ipv6_sock_mc_join" [net/tipc/tipc.ko] undefined!
make[1]: *** [__modpost] Error 1
make: *** [net/tipc/tipc.ko] Error 1

This is because we don't check whether or not the CONFIG_IPV6 is
enabled when calling __ipv6_sock_mc_join().

Fixes: d0f91938bede ("tipc: add ip/udp media type")
Reported-by: Wu Fengguang <fengguang.wu@intel.com>
Cc: Kbuild test robot <kbuild-all@01.org>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/udp_media.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index fc2fb11..6763002 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -247,10 +247,12 @@ static int enable_mcast(struct udp_bearer *ub, struct udp_media_addr *remote)
 		mreqn.imr_multiaddr = remote->ipv4;
 		mreqn.imr_ifindex = ub->ifindex;
 		err = __ip_mc_join_group(sk, &mreqn);
+#if IS_ENABLED(CONFIG_IPV6)
 	} else {
 		if (!ipv6_addr_is_multicast(&remote->ipv6))
 			return 0;
 		err = __ipv6_sock_mc_join(sk, ub->ifindex, &remote->ipv6);
+#endif
 	}
 	return err;
 }
-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/

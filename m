From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/6] net: Remove LL_ALLOCATED_SPACE
Date: Fri, 18 Nov 2011 20:20:05 +0800
Message-ID: <E1RRNQL-0000lW-3F@gondolin.me.apana.org.au>
References: <20111118121832.GA2868@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	evonlanthen@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, timo.teras@iki.fi
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net: Remove LL_ALLOCATED_SPACE

The macro LL_ALLOCATED_SPACE was ill-conceived.  It applies the
alignment to the sum of needed_headroom and needed_tailroom.  As
the amount that is then reserved for head room is needed_headroom
with alignment, this means that the tail room left may be too small.

Now that all uses of LL_ALLOCATED_SPACE have been removed, this
patch finally removes the macro itself.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/netdevice.h |    5 -----
 1 file changed, 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cbeb586..1568c9d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -272,16 +272,11 @@ struct hh_cache {
  *
  * We could use other alignment values, but we must maintain the
  * relationship HH alignment <= LL alignment.
- *
- * LL_ALLOCATED_SPACE also takes into account the tailroom the device
- * may need.
  */
 #define LL_RESERVED_SPACE(dev) \
 	((((dev)->hard_header_len+(dev)->needed_headroom)&~(HH_DATA_MOD - 1)) + HH_DATA_MOD)
 #define LL_RESERVED_SPACE_EXTRA(dev,extra) \
 	((((dev)->hard_header_len+(dev)->needed_headroom+(extra))&~(HH_DATA_MOD - 1)) + HH_DATA_MOD)
-#define LL_ALLOCATED_SPACE(dev) \
-	((((dev)->hard_header_len+(dev)->needed_headroom+(dev)->needed_tailroom)&~(HH_DATA_MOD - 1)) + HH_DATA_MOD)
 
 struct header_ops {
 	int	(*create) (struct sk_buff *skb, struct net_device *dev,

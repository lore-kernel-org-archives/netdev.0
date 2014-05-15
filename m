From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 4/4] vti6: delete unneeded call to netdev_priv
Date: Thu, 15 May 2014 05:43:21 +0200
Message-ID: <1400125401-15512-4-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Netdev_priv is an accessor function, and has no purpose if its result is
not used.

A simplified version of the semantic match that fixes this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@ local idexpression x; @@
-x = netdev_priv(...);
... when != x
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 net/ipv6/ip6_vti.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 6cc9f93..9aaa6bb 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -795,15 +795,12 @@ static const struct net_device_ops vti6_netdev_ops = {
  **/
 static void vti6_dev_setup(struct net_device *dev)
 {
-	struct ip6_tnl *t;
-
 	dev->netdev_ops = &vti6_netdev_ops;
 	dev->destructor = vti6_dev_free;
 
 	dev->type = ARPHRD_TUNNEL6;
 	dev->hard_header_len = LL_MAX_HEADER + sizeof(struct ipv6hdr);
 	dev->mtu = ETH_DATA_LEN;
-	t = netdev_priv(dev);
 	dev->flags |= IFF_NOARP;
 	dev->addr_len = sizeof(struct in6_addr);
 	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;

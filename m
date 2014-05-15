From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 3/4] ip_tunnel: delete unneeded call to netdev_priv
Date: Thu, 15 May 2014 05:43:20 +0200
Message-ID: <1400125401-15512-3-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
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
 net/ipv4/ip_tunnel.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index b3f8597..059176d 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -395,11 +395,10 @@ static struct ip_tunnel *ip_tunnel_create(struct net *net,
 					  struct ip_tunnel_net *itn,
 					  struct ip_tunnel_parm *parms)
 {
-	struct ip_tunnel *nt, *fbt;
+	struct ip_tunnel *nt;
 	struct net_device *dev;
 
 	BUG_ON(!itn->fb_tunnel_dev);
-	fbt = netdev_priv(itn->fb_tunnel_dev);
 	dev = __ip_tunnel_create(net, itn->fb_tunnel_dev->rtnl_link_ops, parms);
 	if (IS_ERR(dev))
 		return ERR_CAST(dev);

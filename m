From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] ipip: dereferencing an ERR_PTR in ip_tunnel_init_net()
Date: Mon, 19 Aug 2013 10:05:10 +0300
Message-ID: <20130819070510.GE28591@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We need to move the derefernce after the IS_ERR() check.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index a4d9126..24549b4 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -854,14 +854,14 @@ int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
 
 	rtnl_lock();
 	itn->fb_tunnel_dev = __ip_tunnel_create(net, ops, &parms);
-	/* FB netdevice is special: we have one, and only one per netns.
-	 * Allowing to move it to another netns is clearly unsafe.
-	 */
-	itn->fb_tunnel_dev->features |= NETIF_F_NETNS_LOCAL;
 	rtnl_unlock();
 
 	if (IS_ERR(itn->fb_tunnel_dev))
 		return PTR_ERR(itn->fb_tunnel_dev);
+	/* FB netdevice is special: we have one, and only one per netns.
+	 * Allowing to move it to another netns is clearly unsafe.
+	 */
+	itn->fb_tunnel_dev->features |= NETIF_F_NETNS_LOCAL;
 
 	return 0;
 }

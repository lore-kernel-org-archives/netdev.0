From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] gre: information leak in ip6_tnl_ioctl()
Date: Thu, 16 Aug 2012 16:14:04 +0300
Message-ID: <20120816131404.GA23188@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:35063 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756178Ab2HPNPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 09:15:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a one byte hole between p->hop_limit and p->flowinfo where
stack memory is leaked to the user.  This was introduced in c12b395a46
"gre: Support GRE over IPv6".

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
This is only needed in linux-next.

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 33d2a0e..cb7e2de 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1312,6 +1312,8 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			}
 			ip6_tnl_parm_from_user(&p1, &p);
 			t = ip6_tnl_locate(net, &p1, 0);
+		} else {
+			memset(&p, 0, sizeof(p));
 		}
 		if (t == NULL)
 			t = netdev_priv(dev);

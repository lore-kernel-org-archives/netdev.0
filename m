From: Noriaki TAKAMIYA <takamiya@linux-ipv6.org>
Subject: [PATCH] IPv6: fix to set device name when new IPv6 over IPv6
 tunnel device is created.
Date: Tue, 10 Feb 2009 03:46:42 +0900 (JST)
Message-ID: <20090210.034642.74753917.takamiya@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: takamiya@po.ntts.co.jp, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	usagi-core@ml.linux-ipv6.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nezu.linux-ipv6.org ([203.178.142.218]:47384 "EHLO
	nezu.linux-ipv6.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752549AbZBITKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 14:10:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

  When the user creates IPv6 over IPv6 tunnel, the device name created
  by the kernel isn't set to t->parm.name, which is referred as the
  result of ioctl().

  Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
---
 net/ipv6/ip6_tunnel.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 58e2b0d..d994c55 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -249,8 +249,8 @@ static struct ip6_tnl *ip6_tnl_create(struct net *net, struct ip6_tnl_parm *p)
 	}
 
 	t = netdev_priv(dev);
-	ip6_tnl_dev_init(dev);
 	t->parms = *p;
+	ip6_tnl_dev_init(dev);
 
 	if ((err = register_netdevice(dev)) < 0)
 		goto failed_free;
-- 
Noriaki TAKAMIYA


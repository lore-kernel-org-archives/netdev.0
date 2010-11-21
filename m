From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH] ipv6: fix inet6_dev refcnt with IPV6_PRIVACY enabled
Date: Sun, 21 Nov 2010 21:58:05 +0200
Message-ID: <20101121195805.GA4068@swordfish>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:60108 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755471Ab0KUT5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Nov 2010 14:57:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When IPV6_PRIVACY is enabled, in ipv6_add_dev we have second extra 
in6_dev_hold while preparing to call ipv6_regen_rndid, and only 
one in6_dev_put call in addrconf_ifdown for inet6_dev devices with 
active regen_timer.

That leaves inet6_dev with refcnt equals to 1 and blocks device unregistration:
"unregister_netdevice: waiting for usb0 to become free. Usage count = 1"

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

---

 net/ipv6/addrconf.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 2fc35b3..541f773 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -425,7 +425,6 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 		       dev->name);
 		ndev->cnf.use_tempaddr = -1;
 	} else {
-		in6_dev_hold(ndev);
 		ipv6_regen_rndid((unsigned long) ndev);
 	}
 #endif


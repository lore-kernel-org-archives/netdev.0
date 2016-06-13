From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 2/3] net: ipv6: Do not add multicast route for l3 master devices
Date: Mon, 13 Jun 2016 13:44:18 -0700
Message-ID: <1465850659-27830-3-git-send-email-dsa@cumulusnetworks.com>
References: <1465850659-27830-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33905 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422685AbcFMUod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 16:44:33 -0400
Received: by mail-pf0-f182.google.com with SMTP id 62so49556367pfd.1
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 13:44:27 -0700 (PDT)
In-Reply-To: <1465850659-27830-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

L3 master devices are virtual devices similar to the loopback
device. Link local and multicast routes for these devices do
not make sense. The ipv6 addrconf code already skips adding a
linklocal address; do the same for the mcast route.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv6/addrconf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 47f837a58e0a..b12553905e42 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2254,7 +2254,7 @@ static struct inet6_dev *addrconf_add_dev(struct net_device *dev)
 		return ERR_PTR(-EACCES);
 
 	/* Add default multicast route */
-	if (!(dev->flags & IFF_LOOPBACK))
+	if (!(dev->flags & IFF_LOOPBACK) && !netif_is_l3_master(dev))
 		addrconf_add_mroute(dev);
 
 	return idev;
-- 
2.1.4

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv6: remove old token ipv6 address as soon as possible
Date: Mon, 24 Jun 2013 22:03:28 +0200
Message-ID: <20130624200328.GJ13836@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: dborkman@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35097 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775Ab3FXUD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 16:03:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the tokenized ip address is re-set on an interface we depend on the
arrival of a new router advertisment to call addrconf_verify to clean
up the old address (which valid_lft is now set to 0). Old addresses can
linger around for a longer time if e.g. the source of router advertisments
vanishes.

So, call addrconf_verify immediately after setting the new tokenized
address to get rid of the old tokenized addresses.

Cc: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/addrconf.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 90788a1..ffc280f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4363,6 +4363,7 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 	}
 
 	write_unlock_bh(&idev->lock);
+	addrconf_verify(0);
 	return 0;
 }
 
-- 
1.8.1.4

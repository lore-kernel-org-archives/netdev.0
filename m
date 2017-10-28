From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] netfilter: ipset: ip_set_bitmap_port: use swap macro in
 bitmap_port_create
Date: Sat, 28 Oct 2017 15:30:07 -0500
Message-ID: <20171028203007.GA4345@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway32.websitewelcome.com ([192.185.145.108]:42495 "EHLO
        gateway32.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751435AbdJ1UaJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 16:30:09 -0400
Received: from cm13.websitewelcome.com (cm13.websitewelcome.com [100.42.49.6])
        by gateway32.websitewelcome.com (Postfix) with ESMTP id 221187685
        for <netdev@vger.kernel.org>; Sat, 28 Oct 2017 15:30:09 -0500 (CDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make use of the swap macro and remove unnecessary variable tmp.
This makes the code easier to read and maintain.

This code was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/netfilter/ipset/ip_set_bitmap_port.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
index 7f9bbd7..b561ca8 100644
--- a/net/netfilter/ipset/ip_set_bitmap_port.c
+++ b/net/netfilter/ipset/ip_set_bitmap_port.c
@@ -238,12 +238,8 @@ bitmap_port_create(struct net *net, struct ip_set *set, struct nlattr *tb[],
 
 	first_port = ip_set_get_h16(tb[IPSET_ATTR_PORT]);
 	last_port = ip_set_get_h16(tb[IPSET_ATTR_PORT_TO]);
-	if (first_port > last_port) {
-		u16 tmp = first_port;
-
-		first_port = last_port;
-		last_port = tmp;
-	}
+	if (first_port > last_port)
+		swap(first_port, last_port);
 
 	elements = last_port - first_port + 1;
 	set->dsize = ip_set_elem_len(set, tb, 0, 0);
-- 
2.7.4

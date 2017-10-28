From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] netfilter: ipset: ip_set_bitmap_ip: use swap macro in
 bitmap_ip_create
Date: Sat, 28 Oct 2017 15:24:05 -0500
Message-ID: <20171028202405.GA913@embeddedor.com>
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
Received: from gateway31.websitewelcome.com ([192.185.144.91]:40685 "EHLO
        gateway31.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751442AbdJ1UYH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 16:24:07 -0400
Received: from cm14.websitewelcome.com (cm14.websitewelcome.com [100.42.49.7])
        by gateway31.websitewelcome.com (Postfix) with ESMTP id 2ADB868E549
        for <netdev@vger.kernel.org>; Sat, 28 Oct 2017 15:24:07 -0500 (CDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make use of the swap macro and remove unnecessary variable tmp.
This makes the code easier to read and maintain.

This code was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/netfilter/ipset/ip_set_bitmap_ip.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index d8975a0..488d6d0 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -263,12 +263,8 @@ bitmap_ip_create(struct net *net, struct ip_set *set, struct nlattr *tb[],
 		ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP_TO], &last_ip);
 		if (ret)
 			return ret;
-		if (first_ip > last_ip) {
-			u32 tmp = first_ip;
-
-			first_ip = last_ip;
-			last_ip = tmp;
-		}
+		if (first_ip > last_ip)
+			swap(first_ip, last_ip);
 	} else if (tb[IPSET_ATTR_CIDR]) {
 		u8 cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
 
-- 
2.7.4

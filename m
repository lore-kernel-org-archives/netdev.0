From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/6] vti4: Don't count header length twice.
Date: Thu, 15 May 2014 09:07:52 +0200
Message-ID: <1400137676-27565-3-git-send-email-steffen.klassert@secunet.com>
References: <1400137676-27565-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44795 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753792AbaEOHIS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 03:08:18 -0400
In-Reply-To: <1400137676-27565-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently count the size of LL_MAX_HEADER and struct iphdr
twice for vti4 devices, this leads to a wrong device mtu.
The size of LL_MAX_HEADER and struct iphdr is already counted in
ip_tunnel_bind_dev(), so don't do it again in vti_tunnel_init().

Fixes: b9959fd3 ("vti: switch to new ip tunnel code")
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_vti.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 687ddef..cd62596 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -349,7 +349,6 @@ static int vti_tunnel_init(struct net_device *dev)
 	memcpy(dev->broadcast, &iph->daddr, 4);
 
 	dev->type		= ARPHRD_TUNNEL;
-	dev->hard_header_len	= LL_MAX_HEADER + sizeof(struct iphdr);
 	dev->mtu		= ETH_DATA_LEN;
 	dev->flags		= IFF_NOARP;
 	dev->iflink		= 0;
-- 
1.7.9.5

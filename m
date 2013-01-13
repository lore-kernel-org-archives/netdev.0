From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 6/7] ipv6 xfrm: Use ipv6_addr_hash() in xfrm6_tunnel_spi_hash_byaddr().
Date: Mon, 14 Jan 2013 00:02:38 +0900
Message-ID: <50F2CC8E.40200@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:38244 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755019Ab3AMPCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 10:02:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/xfrm6_tunnel.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index ee5a706..babd167 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -72,7 +72,7 @@ static inline unsigned int xfrm6_tunnel_spi_hash_byaddr(const xfrm_address_t *ad
 {
 	unsigned int h;
 
-	h = (__force u32)(addr->a6[0] ^ addr->a6[1] ^ addr->a6[2] ^ addr->a6[3]);
+	h = ipv6_addr_hash((const struct in6_addr *)addr);
 	h ^= h >> 16;
 	h ^= h >> 8;
 	h &= XFRM6_TUNNEL_SPI_BYADDR_HSIZE - 1;
-- 
1.7.9.5

From: Eric Dumazet <erdnetdev@gmail.com>
Subject: [PATCH net-next] ipv6: fix a sparse warning
Date: Mon, 18 Feb 2013 12:18:52 -0800
Message-ID: <1361218732.19353.105.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:56715 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753811Ab3BRUS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 15:18:56 -0500
Received: by mail-pa0-f51.google.com with SMTP id hz1so2983497pad.10
        for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 12:18:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

net/ipv6/reassembly.c:82:72: warning: incorrect type in argument 3 (different base types)
net/ipv6/reassembly.c:82:72:    expected unsigned int [unsigned] [usertype] c
net/ipv6/reassembly.c:82:72:    got restricted __be32 [usertype] id

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
---
 net/ipv6/reassembly.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 9a6428a..3c6a772 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -79,7 +79,8 @@ unsigned int inet6_hash_frag(__be32 id, const struct in6_addr *saddr,
 {
 	u32 c;
 
-	c = jhash_3words(ipv6_addr_hash(saddr), ipv6_addr_hash(daddr), id, rnd);
+	c = jhash_3words(ipv6_addr_hash(saddr), ipv6_addr_hash(daddr),
+			 (__force u32)id, rnd);
 
 	return c & (INETFRAGS_HASHSZ - 1);
 }

From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/5] netfilter: ip6t_NPT: Fix translation for non-multiple of 32 prefix lengths
Date: Thu,  4 Apr 2013 14:56:09 +0200
Message-ID: <1365080169-6880-6-git-send-email-pablo@netfilter.org>
References: <1365080169-6880-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40170 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760151Ab3DDM4q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 08:56:46 -0400
In-Reply-To: <1365080169-6880-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Schiffer <mschiffer@universe-factory.net>

The bitmask used for the prefix mangling was being calculated
incorrectly, leading to the wrong part of the address being replaced
when the prefix length wasn't a multiple of 32.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/ip6t_NPT.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/netfilter/ip6t_NPT.c b/net/ipv6/netfilter/ip6t_NPT.c
index 33608c6..cb63114 100644
--- a/net/ipv6/netfilter/ip6t_NPT.c
+++ b/net/ipv6/netfilter/ip6t_NPT.c
@@ -57,7 +57,7 @@ static bool ip6t_npt_map_pfx(const struct ip6t_npt_tginfo *npt,
 		if (pfx_len - i >= 32)
 			mask = 0;
 		else
-			mask = htonl(~((1 << (pfx_len - i)) - 1));
+			mask = htonl((1 << (i - pfx_len + 32)) - 1);
 
 		idx = i / 32;
 		addr->s6_addr32[idx] &= mask;
-- 
1.7.10.4

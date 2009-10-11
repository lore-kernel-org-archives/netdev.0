From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RESED PATCH net-next-2.6 2/3] ipv6 sit: Fix 6rd relay address.
Date: Sun, 11 Oct 2009 22:44:45 +0900
Message-ID: <4AD1E14D.6030903@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:53537 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753202AbZJKNp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2009 09:45:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6 sit: Fix 6rd relay address.

Relay's address should be extracted from real IPv6 address
instead of configured prefix.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/sit.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 8594451..193d0c6 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -569,12 +569,12 @@ __be32 try_6rd(struct in6_addr *v6dst, struct ip_tunnel *tunnel)
 		pbw0 = tunnel->ip6rd.prefixlen >> 5;
 		pbi0 = tunnel->ip6rd.prefixlen & 0x1f;
 
-		d = (ntohl(tunnel->ip6rd.prefix.s6_addr32[pbw0]) << pbi0) >>
+		d = (ntohl(v6dst->s6_addr32[pbw0]) << pbi0) >>
 		    tunnel->ip6rd.relay_prefixlen;
 
 		pbi1 = pbi0 - tunnel->ip6rd.relay_prefixlen;
 		if (pbi1 > 0)
-			d |= ntohl(tunnel->ip6rd.prefix.s6_addr32[pbw0 + 1]) >>
+			d |= ntohl(v6dst->s6_addr32[pbw0 + 1]) >>
 			     (32 - pbi1);
 
 		dst = tunnel->ip6rd.relay_prefix | htonl(d);

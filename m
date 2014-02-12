From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH net-next] ipv6: do not set "u" bit for temporary addresses
Date: Wed, 12 Feb 2014 12:08:06 +0100
Message-ID: <1392203286-17833-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:50239 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751878AbaBLLIO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Feb 2014 06:08:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bit 6 of interface identifier was before the "universal/local bit",
indicating local significance only. This rule is now obsoleted by the
RFC 7136, removing all significance of bits in interface identifier.

The new rule is "In all cases, the bits in an IID have no generic
semantics; in other words, they have opaque values.", so we can remove
the setting of bit 6, it will improve the entropy of random addresses.

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 net/ipv6/addrconf.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index ad23569..0b2a18e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1878,7 +1878,6 @@ static void __ipv6_regen_rndid(struct inet6_dev *idev)
 {
 regen:
 	get_random_bytes(idev->rndid, sizeof(idev->rndid));
-	idev->rndid[0] &= ~0x02;
 
 	/*
 	 * <draft-ietf-ipngwg-temp-addresses-v2-00.txt>:
-- 
1.8.5.3

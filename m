From: arno@natisbad.org (Arnaud Ebalard)
Subject: [BUG,PATCH] XFRM: copy_to_user_kmaddress() reports local address twice
Date: Mon, 03 Nov 2008 10:23:27 +0100
Message-ID: <87vdv5uprk.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Andreas Steffen <andreas.steffen@strongswan.org>,
	Martin Willi <martin@strongswan.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moog.chdir.org ([88.191.42.160]:53870 "EHLO moog.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754640AbYKCJZN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 04:25:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Stupid bug, sorry for that. Attached patch is against current net-2.6. 

Cheers,

a+


While adding support for MIGRATE/KMADDRESS in strongSwan (as specified
in draft-ebalard-mext-pfkey-enhanced-migrate-00), Andreas Steffen
noticed that XFRMA_KMADDRESS attribute passed to userland contains the
local address twice (remote provides local address instead of remote
one).

This bug in copy_to_user_kmaddress() affects only key managers that use
native XFRM interface (key managers that use PF_KEY are not affected).

For the record, the bug was in the initial changeset I posted which
added support for KMADDRESS (13c1d18931ebb5cf407cb348ef2cd6284d68902d).

Signed-off-by: Arnaud Ebalard <arno@natisbad.org>
Reported-by: Andreas Steffen <andreas.steffen@strongswan.org>
---
 net/xfrm/xfrm_user.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 4a8a1ab..a278a6f 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1816,7 +1816,7 @@ static int copy_to_user_kmaddress(struct xfrm_kmaddress *k, struct sk_buff *skb)
 	uk.family = k->family;
 	uk.reserved = k->reserved;
 	memcpy(&uk.local, &k->local, sizeof(uk.local));
-	memcpy(&uk.remote, &k->local, sizeof(uk.remote));
+	memcpy(&uk.remote, &k->remote, sizeof(uk.remote));
 
 	return nla_put(skb, XFRMA_KMADDRESS, sizeof(uk), &uk);
 }
-- 
1.5.6.3

From: andy@greyhouse.net
Subject: [PATCH net-2.6] gro: reset skb_iif on reuse
Date: Wed,  2 Feb 2011 16:27:27 -0500
Message-ID: <1296682047-15885-1-git-send-email-andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24189 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752876Ab1BBVTt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 16:19:49 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id p12LJmta011990
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 2 Feb 2011 16:19:49 -0500
Received: from quad.redhat.com (vpn-11-10.rdu.redhat.com [10.11.11.10])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p12LJm0g003777
	for <netdev@vger.kernel.org>; Wed, 2 Feb 2011 16:19:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Like Herbert's change from a few days ago:

66c46d741e2e60f0e8b625b80edb0ab820c46d7a gro: Reset dev pointer on reuse

this may not be necessary at this point, but we should still clean up
the skb->skb_iif.  If not we may end up with an invalid valid for
skb->skb_iif when the skb is reused and the check is done in
__netif_receive_skb.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---
 net/core/dev.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 4c90789..b6d0bf8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3426,6 +3426,7 @@ static void napi_reuse_skb(struct napi_struct *napi, struct sk_buff *skb)
 	skb_reserve(skb, NET_IP_ALIGN - skb_headroom(skb));
 	skb->vlan_tci = 0;
 	skb->dev = napi->dev;
+	skb->skb_iif = 0;
 
 	napi->skb = skb;
 }
-- 
1.7.3.2


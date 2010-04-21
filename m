From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Introduce skb_orphan_try()
Date: Wed, 21 Apr 2010 08:08:36 +0200
Message-ID: <1271830116.7895.1316.camel@edumazet-laptop>
References: <1271364375.16881.3099.camel@edumazet-laptop>
	 <20100415.143321.200497785.davem@davemloft.net>
	 <1271456302.16881.4559.camel@edumazet-laptop>
	 <20100418.024601.85853662.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:42698 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752441Ab0DUGIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 02:08:45 -0400
Received: by bwz25 with SMTP id 25so7616720bwz.28
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 23:08:43 -0700 (PDT)
In-Reply-To: <20100418.024601.85853662.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 18 avril 2010 =C3=A0 02:46 -0700, David Miller a =C3=A9crit=
 :

> Looks good, applied, thanks Eric.

Hmm, looking at the GSO stuff, I believe we should not call
skb_orphan_try() on gso skbs ?

Thanks !

[PATCH net-next-2.6] net: Dont call skb_orphan_try() for GSO

At this point, skb->destructor is not the original one (stored in
DEV_GSO_CB(skb)->destructor)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/dev.c b/net/core/dev.c
index b31d5d6..200d1e8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1937,7 +1937,6 @@ gso:
 		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
 			skb_dst_drop(nskb);
=20
-		skb_orphan_try(nskb);
 		rc =3D ops->ndo_start_xmit(nskb, dev);
 		if (unlikely(rc !=3D NETDEV_TX_OK)) {
 			if (rc & ~NETDEV_TX_MASK)



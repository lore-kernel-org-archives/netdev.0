From: David Miller <davem@davemloft.net>
Subject: Re: Nested GRE locking bug
Date: Mon, 25 Oct 2010 12:53:47 -0700 (PDT)
Message-ID: <20101025.125347.28807251.davem@davemloft.net>
References: <1287029519.2649.108.camel@edumazet-laptop>
	<20101019.015303.104063240.davem@davemloft.net>
	<1287478956.2676.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ben@decadent.org.uk, netdev@vger.kernel.org,
	beatrice.barbe@gmail.com, 599816@bugs.debian.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53027
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757502Ab0JYTxY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Oct 2010 15:53:24 -0400
In-Reply-To: <1287478956.2676.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 19 Oct 2010 11:02:36 +0200

> Le mardi 19 octobre 2010 =E0 01:53 -0700, David Miller a =E9crit :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Thu, 14 Oct 2010 06:11:59 +0200
>>=20
>> > net-next-2.6 contains a fix for this, adding the perc_cpu
>> > xmit_recursion limit. We might push it to net-2.6
>>=20
>> We need to think a bit more about this.
>>=20
>> We are essentially now saying that one can only configure
>> tunnels 3 levels deep, and no more.
>>=20
>> I can guarentee you someone out there uses at least 4,
>> perhaps more.
>>=20
>> And those people will be broken by the new limit.
>>=20
>> So putting this into net-2.6 with such a low limit will
>> be quite dangerous.
>=20
> Well limit is actually 4, but I get your point ;)

I'll commit the following to upstream, and submit a combined
patch to -stable.

--------------------
net: Increase xmit RECURSION_LIMIT to 10.

Three is definitely too low, and we know from reports that GRE tunnels
stacked as deeply as 37 levels cause stack overflows, so pick some
reasonable value between those two.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 78b5a89..2c7da3a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2213,7 +2213,7 @@ static inline int __dev_xmit_skb(struct sk_buff *=
skb, struct Qdisc *q,
 }
=20
 static DEFINE_PER_CPU(int, xmit_recursion);
-#define RECURSION_LIMIT 3
+#define RECURSION_LIMIT 10
=20
 /**
  *	dev_queue_xmit - transmit a buffer
--=20
1.7.3.2


From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Nested GRE locking bug
Date: Mon, 25 Oct 2010 22:08:25 +0200
Message-ID: <1288037305.3296.0.camel@edumazet-laptop>
References: <1287029519.2649.108.camel@edumazet-laptop>
	 <20101019.015303.104063240.davem@davemloft.net>
	 <1287478956.2676.13.camel@edumazet-laptop>
	 <20101025.125347.28807251.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ben@decadent.org.uk, netdev@vger.kernel.org,
	beatrice.barbe@gmail.com, 599816@bugs.debian.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38154 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757612Ab0JYUIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 16:08:37 -0400
Received: by wyf28 with SMTP id 28so3797658wyf.19
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 13:08:36 -0700 (PDT)
In-Reply-To: <20101025.125347.28807251.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 25 octobre 2010 =C3=A0 12:53 -0700, David Miller a =C3=A9crit =
:

> I'll commit the following to upstream, and submit a combined
> patch to -stable.
>=20
> --------------------
> net: Increase xmit RECURSION_LIMIT to 10.
>=20
> Three is definitely too low, and we know from reports that GRE tunnel=
s
> stacked as deeply as 37 levels cause stack overflows, so pick some
> reasonable value between those two.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/core/dev.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 78b5a89..2c7da3a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2213,7 +2213,7 @@ static inline int __dev_xmit_skb(struct sk_buff=
 *skb, struct Qdisc *q,
>  }
> =20
>  static DEFINE_PER_CPU(int, xmit_recursion);
> -#define RECURSION_LIMIT 3
> +#define RECURSION_LIMIT 10
> =20
>  /**
>   *	dev_queue_xmit - transmit a buffer


Perfect, thanks !




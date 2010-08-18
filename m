From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/8] net: rps: skip fragment when computing rxhash
Date: Wed, 18 Aug 2010 08:25:01 +0200
Message-ID: <1282112701.2456.15.camel@edumazet-laptop>
References: <1282107698-3456-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53981 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903Ab0HRGZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 02:25:07 -0400
Received: by wwi17 with SMTP id 17so360274wwi.1
        for <netdev@vger.kernel.org>; Tue, 17 Aug 2010 23:25:06 -0700 (PDT)
In-Reply-To: <1282107698-3456-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 ao=C3=BBt 2010 =C3=A0 13:01 +0800, Changli Gao a =C3=A9c=
rit :
> Fragmented IP packets may have no transfer header, so when computing
> rxhash, we should skip them.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  net/core/dev.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 3f82781..b7c5309 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2284,7 +2284,10 @@ __u32 __skb_get_rxhash(struct sk_buff *skb)
>  			goto done;
> =20
>  		ip =3D (struct iphdr *) skb->data + nhoff;
> -		ip_proto =3D ip->protocol;
> +		if (ip->frag_off & htons(IP_MF|IP_OFFSET))
> +			ip_proto =3D 0;
> +		else
> +			ip_proto =3D ip->protocol;
>  		addr1 =3D (__force u32) ip->saddr;
>  		addr2 =3D (__force u32) ip->daddr;
>  		ihl =3D ip->ihl;

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

BTW, it is nicer to add some spaces :

	if (ip->frag_off & htons(IP_MF | IP_OFFSET))



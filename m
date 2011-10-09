From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] gro: refetch inet6_protos[] after pulling ext headers
Date: Sun, 09 Oct 2011 11:33:51 +0200
Message-ID: <1318152831.5276.30.camel@edumazet-laptop>
References: <4E915C9B.4000807@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:65064 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868Ab1JIJd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2011 05:33:57 -0400
Received: by wwf22 with SMTP id 22so7817151wwf.1
        for <netdev@vger.kernel.org>; Sun, 09 Oct 2011 02:33:56 -0700 (PDT)
In-Reply-To: <4E915C9B.4000807@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 09 octobre 2011 =C3=A0 16:34 +0800, Yan, Zheng a =C3=A9crit=
 :
> ipv6_gro_receive() doesn't update the protocol ops after pulling
> the ext headers. It looks like a typo.
>=20
> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
> ---
> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> index 3b5669a..d27c797 100644
> --- a/net/ipv6/af_inet6.c
> +++ b/net/ipv6/af_inet6.c
> @@ -875,6 +875,7 @@ static struct sk_buff **ipv6_gro_receive(struct s=
k_buff **head,
>  		skb_reset_transport_header(skb);
>  		__skb_push(skb, skb_gro_offset(skb));
> =20
> +		ops =3D rcu_dereference(inet6_protos[proto]);
>  		if (!ops || !ops->gro_receive)
>  			goto out_unlock;

Good catch !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

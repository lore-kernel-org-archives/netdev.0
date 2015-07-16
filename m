From: Wolfgang Walter <linux@stwm.de>
Subject: Re: sit: Set SKB_GSO_SIT bit when performing GRO
Date: Thu, 16 Jul 2015 12:58:45 +0200
Message-ID: <2115027.IFUsFvOUns@stwm.de>
References: <17762800.UBb5paxXY3@h2o.as.studentenwerk.mhn.de> <2477915.Hv2mXUtnDZ@stwm.de> <20150716002350.GA7529@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Tom Herbert <therbert@google.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:48144 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751572AbbGPK6r convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2015 06:58:47 -0400
In-Reply-To: <20150716002350.GA7529@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, 16. Juli 2015, 08:23:50 schrieb Herbert Xu:
> On Wed, Jul 15, 2015 at 02:25:59PM +0200, Wolfgang Walter wrote:
> > Yes. Switching TSO off and leaving GRO on works, too.
>=20
> OK, could you please try this patch?

Patch works here.

Thanks,

Wolfgang

>=20
> ---8<---
> We need to set the SKB_GSO_SIT bit if we detect a 6-in-4 tunnel
> when doing GRO.  Otherwise we may throw a packet at TSO hardware
> that doesn't know what to do with it.
>=20
> Fixes: 19424e052fb4 ("sit: Add gro callbacks to sit_offload")
> Reported-by: Wolfgang Walter <linux@stwm.de>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>=20
> diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
> index e893cd1..1252eac 100644
> --- a/net/ipv6/ip6_offload.c
> +++ b/net/ipv6/ip6_offload.c
> @@ -289,11 +289,21 @@ static struct packet_offload ipv6_packet_offloa=
d
> __read_mostly =3D { },
>  };
>=20
> +static int sit_gro_complete(struct sk_buff *skb, int nhoff)
> +{
> +	int err =3D ipv6_gro_complete(skb, nhoff);
> +
> +	skb->encapsulation =3D 1;
> +	skb_shinfo(skb)->gso_type |=3D SKB_GSO_SIT;
> +
> +	return err;
> +}
> +
>  static const struct net_offload sit_offload =3D {
>  	.callbacks =3D {
>  		.gso_segment	=3D ipv6_gso_segment,
>  		.gro_receive	=3D ipv6_gro_receive,
> -		.gro_complete	=3D ipv6_gro_complete,
> +		.gro_complete	=3D sit_gro_complete,
>  	},
>  };

--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts

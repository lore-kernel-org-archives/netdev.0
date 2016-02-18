From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix bridge multicast packet checksum validation
Date: Thu, 18 Feb 2016 15:35:42 -0500 (EST)
Message-ID: <20160218.153542.67284853154438064.davem@davemloft.net>
References: <1455502026-23144-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	sgunderson@bigfoot.com, noltari@gmail.com, tom@herbertland.com
To: linus.luessing@c0d3.blue
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455502026-23144-1-git-send-email-linus.luessing@c0d3.blue>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Linus L=FCssing <linus.luessing@c0d3.blue>
Date: Mon, 15 Feb 2016 03:07:06 +0100

> @@ -4084,10 +4089,22 @@ struct sk_buff *skb_checksum_trimmed(struct s=
k_buff *skb,
>  	if (!pskb_may_pull(skb_chk, offset))
>  		goto err;
> =20
> -	__skb_pull(skb_chk, offset);
> +	ip_summed =3D skb->ip_summed;
> +	csum_valid =3D skb->csum_valid;
> +	csum_level =3D skb->csum_level;
> +	csum_bad =3D skb->csum_bad;
> +	csum =3D skb->csum;
> +
> +	skb_pull_rcsum(skb_chk, offset);
>  	ret =3D skb_chkf(skb_chk);
>  	__skb_push(skb_chk, offset);
> =20
> +	skb->ip_summed =3D ip_summed;
> +	skb->csum_valid =3D csum_valid;
> +	skb->csum_level =3D csum_level;
> +	skb->csum_bad =3D csum_bad;
> +	skb->csum =3D csum;
> +

There really has to be a better way to fix this :-/

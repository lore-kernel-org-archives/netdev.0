From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 01/10] tcp: force mss equality with the next skb too.
Date: Fri, 05 Dec 2008 23:13:35 +0100
Message-ID: <87abbaw9rk.fsf@basil.nowhere.org>
References: <1228510736-3655-1-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1228510736-3655-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?utf-8?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:55820 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753629AbYLEWNU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 17:13:20 -0500
In-Reply-To: <1228510736-3655-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 (Ilpo =?utf-8?Q?J=C3=A4rvinen's?= message of "Fri,  5 Dec 2008 22:58:47
 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> writes:
> +++ b/net/ipv4/tcp_input.c
> @@ -1575,11 +1575,10 @@ static struct sk_buff *tcp_shift_skb_data(str=
uct sock *sk, struct sk_buff *skb,
>  		goto out;
>  	skb =3D tcp_write_queue_next(sk, prev);
> =20
> -	if (!skb_can_shift(skb))
> -		goto out;
> -	if (skb =3D=3D tcp_send_head(sk))
> -		goto out;
> -	if ((TCP_SKB_CB(skb)->sacked & TCPCB_TAGBITS) !=3D TCPCB_SACKED_ACK=
ED)
> +	if (!skb_can_shift(skb) ||
> +	    (skb =3D=3D tcp_send_head(sk)) ||
> +	    ((TCP_SKB_CB(skb)->sacked & TCPCB_TAGBITS) !=3D TCPCB_SACKED_AC=
KED) ||
> +	    (mss !=3D tcp_shift_mss(skb)))
>  		goto out;

Perhaps it's just me, but I think the code was far more readable
before your change.

-Andi

--=20
ak@linux.intel.com

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/6] skb: Add skb_peek_next helper
Date: Tue, 21 Feb 2012 18:43:53 +0100
Message-ID: <1329846233.18384.23.camel@edumazet-laptop>
References: <4F43D49E.3010401@parallels.com>
	 <4F43D4E6.4060206@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:58166 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148Ab2BURn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 12:43:58 -0500
Received: by wics10 with SMTP id s10so3669355wic.19
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 09:43:57 -0800 (PST)
In-Reply-To: <4F43D4E6.4060206@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 f=C3=A9vrier 2012 =C3=A0 21:31 +0400, Pavel Emelyanov a =C3=
=A9crit :
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>=20
> ---
>  include/linux/skbuff.h |   18 ++++++++++++++++++
>  1 files changed, 18 insertions(+), 0 deletions(-)
>=20
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index f3cf43d..c11a44e 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -877,6 +877,24 @@ static inline struct sk_buff *skb_peek(const str=
uct sk_buff_head *list_)
>  }
> =20
>  /**
> + *	skb_peek_next - peek skb following the given one from a queue
> + *	@skb: skb to start from
> + *	@list_: list to peek at
> + *
> + *	Returns %NULL when the end of the list is met or a pointer to the
> + *	next element. The reference count is not incremented and the
> + *	reference is therefore volatile. Use with caution.
> + */
> +static inline struct sk_buff *skb_peek_next(struct sk_buff *skb,
> +		const struct sk_buff_head *list_)
> +{
> +	struct sk_buff *next =3D skb->next;
> +	if (next =3D=3D (struct sk_buff *)list_)
> +		next =3D NULL;
> +	return next;
> +}
> +
> +/**
>   *	skb_peek_tail - peek at the tail of an &sk_buff_head
>   *	@list_: list to peek at
>   *

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

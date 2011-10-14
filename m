From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] skbuff: update sk truesize in pskb_expand_head
Date: Fri, 14 Oct 2011 09:53:49 +0200
Message-ID: <1318578829.2533.100.camel@edumazet-laptop>
References: <1318577970-19566-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57046 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755992Ab1JNHx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 03:53:56 -0400
Received: by wwf22 with SMTP id 22so3035696wwf.1
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 00:53:55 -0700 (PDT)
In-Reply-To: <1318577970-19566-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 14 octobre 2011 =C3=A0 15:39 +0800, roy.qing.li@gmail.com a
=C3=A9crit :
> when pskb_expand_head reallocates header of &sk_buff, the sk
> truesize should be updated simultaneously
>=20
> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
> ---
>  net/core/skbuff.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 387703f..48e0be9 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -920,6 +920,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhe=
ad, int ntail,
>  	}
>  	off =3D (data + nhead) - skb->head;
> =20
> +	skb->truesize +=3D (size - (skb_end_pointer(skb) - skb->head));
>  	skb->head     =3D data;
>  adjust_others:
>  	skb->data    +=3D off;

I dont believe this is needed or complete patch.

Callers that need an updated truesize do the adjustement.

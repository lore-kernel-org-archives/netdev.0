From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: net: allow handlers to be processed for orig_dev
Date: Tue, 01 Mar 2011 09:24:19 +0100
Message-ID: <4D6CAD33.2090706@gmail.com>
References: <20110301062631.GC2855@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:47264 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755519Ab1CAIY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 03:24:26 -0500
Received: by fxm17 with SMTP id 17so4561585fxm.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 00:24:24 -0800 (PST)
In-Reply-To: <20110301062631.GC2855@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/03/2011 07:26, Jiri Pirko a =E9crit :
> This was there before, I forgot about this. Allows deliveries to
> ptype_base handlers registered for orig_dev. I presume this is still
> desired.

Yes, it is. Sorry for missing it in my review.

> Signed-off-by: Jiri Pirko<jpirko@redhat.com>

Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

> ---
>   net/core/dev.c |    3 ++-
>   1 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 30440e7..9f66de9 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3208,7 +3208,8 @@ ncls:
>   	list_for_each_entry_rcu(ptype,
>   			&ptype_base[ntohs(type)&  PTYPE_HASH_MASK], list) {
>   		if (ptype->type =3D=3D type&&
> -		    (ptype->dev =3D=3D null_or_dev || ptype->dev =3D=3D skb->dev))=
 {
> +		    (ptype->dev =3D=3D null_or_dev || ptype->dev =3D=3D skb->dev |=
|
> +		     ptype->dev =3D=3D orig_dev)) {
>   			if (pt_prev)
>   				ret =3D deliver_skb(skb, pt_prev, orig_dev);
>   			pt_prev =3D ptype;


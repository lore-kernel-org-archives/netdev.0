From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] netdevice.h: Align struct netdevices members
Date: Tue, 10 May 2011 05:53:15 +0200
Message-ID: <1304999595.3050.45.camel@edumazet-laptop>
References: <1304998966.19586.104.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37192 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455Ab1EJDxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 23:53:20 -0400
Received: by wwa36 with SMTP id 36so6423366wwa.1
        for <netdev@vger.kernel.org>; Mon, 09 May 2011 20:53:19 -0700 (PDT)
In-Reply-To: <1304998966.19586.104.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 09 mai 2011 =C3=A0 20:42 -0700, Joe Perches a =C3=A9crit :
> Save a bit of space.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  include/linux/netdevice.h |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
>=20

Hmm... correct alignements are far more important for this structure.

Did you run benchmarks on 32bit and 64bit platforms ?

BTW we have ____cacheline_aligned_in_smp markers, I am not even sure
this patch saves space.

> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index d5de66a..0fcb86b 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1020,9 +1020,6 @@ struct net_device {
>  	 *	part of the usual set specified in Space.c.
>  	 */
> =20
> -	unsigned char		if_port;	/* Selectable AUI, TP,..*/
> -	unsigned char		dma;		/* DMA channel		*/
> -
>  	unsigned long		state;
> =20
>  	struct list_head	dev_list;
> @@ -1141,13 +1138,16 @@ struct net_device {
>  	const struct header_ops *header_ops;
> =20
>  	unsigned int		flags;	/* interface flags (a la BSD)	*/
> +	unsigned int		priv_flags; /* Like 'flags' but invisible to userspac=
e. */
>  	unsigned short		gflags;
> -        unsigned int            priv_flags; /* Like 'flags' but invi=
sible to userspace. */
>  	unsigned short		padded;	/* How much padding added by alloc_netdev()=
 */
> =20
>  	unsigned char		operstate; /* RFC2863 operstate */
>  	unsigned char		link_mode; /* mapping policy to operstate */
> =20
> +	unsigned char		if_port;	/* Selectable AUI, TP,..*/
> +	unsigned char		dma;		/* DMA channel		*/
> +
>  	unsigned int		mtu;	/* interface MTU value		*/
>  	unsigned short		type;	/* interface hardware type	*/
>  	unsigned short		hard_header_len;	/* hardware hdr length	*/
>=20



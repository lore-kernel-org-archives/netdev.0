From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] udp_diag: Fix the !ipv6 case
Date: Sat, 10 Dec 2011 12:02:11 +0100
Message-ID: <1323514931.4016.17.camel@edumazet-laptop>
References: <4EE23561.5020804@parallels.com>
		 <4EE23626.6000104@parallels.com>
	 <1323467297.4016.10.camel@edumazet-laptop> <4EE32167.2080202@parallels.com>
	 <4EE32777.2030003@parallels.com> <4EE327CB.4040505@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:48666 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752381Ab1LJLCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2011 06:02:16 -0500
Received: by eekc4 with SMTP id c4so769146eek.19
        for <netdev@vger.kernel.org>; Sat, 10 Dec 2011 03:02:15 -0800 (PST)
In-Reply-To: <4EE327CB.4040505@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 10 d=C3=A9cembre 2011 =C3=A0 13:35 +0400, Pavel Emelyanov a =C3=
=A9crit :
> Wrap the udp6 lookup into the proper ifdef-s.
>=20
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>=20
> ---
>=20
> diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
> index 6506344..df7f960 100644
> --- a/net/ipv4/udp_diag.c
> +++ b/net/ipv4/udp_diag.c
> @@ -41,6 +41,7 @@ static int udp_dump_one(struct udp_table *tbl, stru=
ct sk_buff *in_skb,
>  				req->id.idiag_src[0], req->id.idiag_sport,
>  				req->id.idiag_dst[0], req->id.idiag_dport,
>  				req->id.idiag_if, tbl);
> +#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)

strange space after second 'defined' ;)

By the way, we can now use :

#if IS_ENABLED(CONFIG_IPV6)

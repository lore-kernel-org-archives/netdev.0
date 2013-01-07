From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH 2/2] ipv6: fix packet corruption when Dest/RT2 options
 are used
Date: Mon, 07 Jan 2013 11:49:51 +0100
Message-ID: <50EAA84F.90408@6wind.com>
References: <0CC79564-4AF2-42F9-8D06-1BCC912A1AF7@ipflavors.com> <C7895CAA-0AF7-4EED-B9E7-9D8E4A21442B@ipflavors.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Romain KUNTZ <r.kuntz@ipflavors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f42.google.com ([209.85.214.42]:36986 "EHLO
	mail-bk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753638Ab3AGKtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 05:49:55 -0500
Received: by mail-bk0-f42.google.com with SMTP id ji2so8297446bkc.29
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2013 02:49:53 -0800 (PST)
In-Reply-To: <C7895CAA-0AF7-4EED-B9E7-9D8E4A21442B@ipflavors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/01/2013 17:19, Romain KUNTZ a =E9crit :
> Commit 299b0767 (ipv6: Fix IPsec slowpath fragmentation problem)
Add Steffen into CC, he is the author of this patch and the IPsec
maintainer.

> has introduced a bug that provokes corrupted packets when Destination
> Options or Routing Header Type 2 are used (such as with Mobile IPv6):
> rt->rt6i_nfheader_len should be substracted to rt->dst.header_len,
> and not to exthdrlen.
>
> This patch reverts to the original and correct behavior. Successfully
> tested with and without IPsec activated for MH packets.
>
> Signed-off-by: Romain Kuntz <r.kuntz@ipflavors.com>
> ---
>   net/ipv6/ip6_output.c |    4 ++--
>   1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 5552d13..0c7c03d 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -1213,10 +1213,10 @@ int ip6_append_data(struct sock *sk, int getf=
rag(void *from, char *to,
>   		if (dst_allfrag(rt->dst.path))
>   			cork->flags |=3D IPCORK_ALLFRAG;
>   		cork->length =3D 0;
> -		exthdrlen =3D (opt ? opt->opt_flen : 0) - rt->rt6i_nfheader_len;
> +		exthdrlen =3D (opt ? opt->opt_flen : 0);
>   		length +=3D exthdrlen;
>   		transhdrlen +=3D exthdrlen;
> -		dst_exthdrlen =3D rt->dst.header_len;
> +		dst_exthdrlen =3D rt->dst.header_len - rt->rt6i_nfheader_len;
>   	} else {
>   		rt =3D (struct rt6_info *)cork->dst;
>   		fl6 =3D &inet->cork.fl.u.ip6;
>

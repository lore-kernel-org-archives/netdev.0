From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] ila: ipv6/ila: fix nlsize calculation for
 lwtunnel
Date: Fri, 29 Apr 2016 09:40:08 +0200
Message-ID: <57230FD8.8030609@6wind.com>
References: <1461888749-4105343-1-git-send-email-tom@herbertland.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36230 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbcD2HkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 03:40:11 -0400
Received: by mail-wm0-f49.google.com with SMTP id n129so16442925wmn.1
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 00:40:10 -0700 (PDT)
In-Reply-To: <1461888749-4105343-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 29/04/2016 02:12, Tom Herbert a =C3=A9crit :
> The handler 'ila_fill_encap_info' adds two attributes: ILA_ATTR_LOCAT=
OR
> and ILA_ATTR_CSUM_MODE.
>=20
> Also, do nla_put_u8 instead of nla_put_u64 for ILA_ATTR_CSUM_MODE.
>=20
> Fixes: 65d7ab8de582 ("net: Identifier Locator Addressing module")
> Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  net/ipv6/ila/ila_lwt.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
>=20
> diff --git a/net/ipv6/ila/ila_lwt.c b/net/ipv6/ila/ila_lwt.c
> index 4985e1a..7788090 100644
> --- a/net/ipv6/ila/ila_lwt.c
> +++ b/net/ipv6/ila/ila_lwt.c
> @@ -133,7 +133,7 @@ static int ila_fill_encap_info(struct sk_buff *sk=
b,
>  	if (nla_put_u64_64bit(skb, ILA_ATTR_LOCATOR, (__force u64)p->locato=
r.v64,
>  			      ILA_ATTR_PAD))
>  		goto nla_put_failure;
> -	if (nla_put_u64(skb, ILA_ATTR_CSUM_MODE, (__force u8)p->csum_mode))
> +	if (nla_put_u8(skb, ILA_ATTR_CSUM_MODE, (__force u8)p->csum_mode))
>  		goto nla_put_failure;
> =20
>  	return 0;
> @@ -144,8 +144,12 @@ nla_put_failure:
> =20
>  static int ila_encap_nlsize(struct lwtunnel_state *lwtstate)
>  {
> -	/* No encapsulation overhead */
> -	return 0;
> +	return
> +		/* ILA_ATTR_LOCATOR */
> +		nla_total_size(sizeof(u64)) +
It should be nla_total_size_64bit() here.


Regards,
Nicolas

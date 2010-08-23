From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: copy_rtnl_link_stats64()
 simplification
Date: Mon, 23 Aug 2010 20:17:45 +0200
Message-ID: <1282587465.2378.10.camel@edumazet-laptop>
References: <1282583676.2486.525.camel@edumazet-laptop>
	 <1282585624.1879.103.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:58814 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670Ab0HWSRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 14:17:51 -0400
Received: by gxk23 with SMTP id 23so2226531gxk.19
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 11:17:50 -0700 (PDT)
In-Reply-To: <1282585624.1879.103.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 23 ao=C3=BBt 2010 =C3=A0 10:47 -0700, Joe Perches a =C3=A9crit=
 :
> On Mon, 2010-08-23 at 19:14 +0200, Eric Dumazet wrote:
> > No need to use a temporary struct rtnl_link_stats64 variable,
> > just copy the source to skb buffer.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Maybe it's better to use the same argument style as copy_rtnl_link_st=
ats
>=20
>  net/core/rtnetlink.c |   36 ++++--------------------------------
>  1 files changed, 4 insertions(+), 32 deletions(-)
>=20
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index f78d821..f8781db 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -610,38 +610,10 @@ static void copy_rtnl_link_stats(struct rtnl_li=
nk_stats *a,
>  	a->tx_compressed =3D b->tx_compressed;
>  }
> =20
> -static void copy_rtnl_link_stats64(void *v, const struct rtnl_link_s=
tats64 *b)
> +static void copy_rtnl_link_stats64(struct rtnl_link_stats64 *a,
> +				   const struct rtnl_link_stats64 *b)
>  {



Nope, we have no quarantee of v being aligned on a u64

If you tell compiler first argument is a pointer to rtnl_link_stats64,
it might use 64bit stores and trap.




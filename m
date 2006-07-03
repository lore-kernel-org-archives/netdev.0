From: Nicolas DICHTEL <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] xfrm6: move define/ifdef check order
Date: Mon, 03 Jul 2006 15:39:40 +0200
Message-ID: <44A91E1C.7010701@6wind.com>
References: <20060702143611.dffe7b15.rdunlap@xenotime.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail01.net-streams.fr ([62.23.133.110]:9231 "EHLO
	net-streams.fr") by vger.kernel.org with ESMTP id S1750794AbWGCNhq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 09:37:46 -0400
To: "Randy.Dunlap" <rdunlap@xenotime.net>
In-Reply-To: <20060702143611.dffe7b15.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I point out this issue a long time ago ...
http://marc.theaimsgroup.com/?l=3Dlinux-netdev&m=3D113032946908126&w=3D=
2


Regards,
Nicolas

Randy.Dunlap a =E9crit :
> From: Randy Dunlap <rdunlap@xenotime.net>
>
> The first check for #ifdef XFRM6_TUNNEL_SPI_MAGIC needs to come after
> the optional #define of it, otherwise the variable won't be there
> for the rest of the code to use.
>
> Shouldn't that CONFIG_IPV6_XFRM6_TUNNEL_DEBUG be part of Kconfig
> or have its name changed?
>
> Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
> ---
>  net/ipv6/xfrm6_tunnel.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
>
> --- linux-2617-g20.orig/net/ipv6/xfrm6_tunnel.c
> +++ linux-2617-g20/net/ipv6/xfrm6_tunnel.c
> @@ -52,6 +52,10 @@
>  # define X6TPRINTK3	X6TNOPRINTK
>  #endif
> =20
> +#ifdef CONFIG_IPV6_XFRM6_TUNNEL_DEBUG
> +# define XFRM6_TUNNEL_SPI_MAGIC 0xdeadbeef
> +#endif
> +
>  /*
>   * xfrm_tunnel_spi things are for allocating unique id ("spi")=20
>   * per xfrm_address_t.
> @@ -67,10 +71,6 @@ struct xfrm6_tunnel_spi {
>  #endif
>  };
> =20
> -#ifdef CONFIG_IPV6_XFRM6_TUNNEL_DEBUG
> -# define XFRM6_TUNNEL_SPI_MAGIC 0xdeadbeef
> -#endif
> -
>  static DEFINE_RWLOCK(xfrm6_tunnel_spi_lock);
> =20
>  static u32 xfrm6_tunnel_spi;
>
>
> ---
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>

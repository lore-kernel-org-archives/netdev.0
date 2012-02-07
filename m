From: Anisse Astier <anisse@astier.eu>
Subject: Re: [PATCH] net: Default UDP and UNIX diag to 'n'.
Date: Tue, 7 Feb 2012 14:51:20 +0100
Message-ID: <20120207145120.26905922@destiny.ordissimo>
References: <20120107.121339.633839797125273714.davem@davemloft.net>
	<20120207121256.50667809@destiny.ordissimo>
	<4F31292F.2090503@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:46088 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756554Ab2BGNvb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 08:51:31 -0500
Received: by werb13 with SMTP id b13so5022823wer.19
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2012 05:51:30 -0800 (PST)
In-Reply-To: <4F31292F.2090503@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 07 Feb 2012 17:37:51 +0400, Pavel Emelyanov <xemul@parallels.co=
m> wrote :

> >> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> >> index 1a8f93b..43e1439 100644
> >> --- a/net/ipv4/Kconfig
> >> +++ b/net/ipv4/Kconfig
> >> @@ -410,8 +410,12 @@ config INET_TCP_DIAG
> >>  	def_tristate INET_DIAG
> >> =20
> >>  config INET_UDP_DIAG
> >> +	tristate "UDP: socket monitoring interface"
> >>  	depends on INET_DIAG
> >> -	def_tristate INET_DIAG && IPV6
> > This broke earlier patch=20
> > b872a2371ffd13e6d83423ef621a707df4c158ac "udp_diag: Make it module =
when ipv6 is a module",
> > which brings back the compilation error when compiling linus master=
 (v3.3-rc2+):
> >=20
> > net/built-in.o: In function `udp_dump_one':
> > udp_diag.c:(.text+0x59852): undefined reference to `__udp6_lib_look=
up'
> >=20
> >=20
> >> +	default n
> >> +	---help---
> >> +	  Support for UDP socket monitoring interface used by the ss too=
l.
> >> +	  If unsure, say Y.
> >> =20
>=20
> I assume you have CONFIG_IPV6=3Dm and CONFIG_INET_UDP_DIAG=3Dy, right=
?

That's correct.

> This one should fix the issue, you'll not be able to set it to Y when
> IPV6 is M.

Indeed, it fixes the issue, but it also prevents using UDP_DIAG without
IPv6 (just like the previous patch I=C2=A0guess.). Not a problem for me=
=2E

>=20
>=20
> [PATCH] udp_diag: Add dependency on IPV6
>=20
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>=20
> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> index aa2a2c7..55d39a4 100644
> --- a/net/ipv4/Kconfig
> +++ b/net/ipv4/Kconfig
> @@ -409,7 +409,7 @@ config INET_TCP_DIAG
> =20
>  config INET_UDP_DIAG
>  	tristate "UDP: socket monitoring interface"
> -	depends on INET_DIAG
> +	depends on INET_DIAG && IPV6
>  	default n
>  	---help---
>  	  Support for UDP socket monitoring interface used by the ss tool.

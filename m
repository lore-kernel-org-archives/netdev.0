From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Default UDP and UNIX diag to 'n'.
Date: Tue, 07 Feb 2012 12:29:00 -0500 (EST)
Message-ID: <20120207.122900.1158401078057884372.davem@davemloft.net>
References: <20120207121256.50667809@destiny.ordissimo>
	<4F31292F.2090503@parallels.com>
	<20120207145120.26905922@destiny.ordissimo>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xemul@parallels.com, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: anisse@astier.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34887 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754513Ab2BGR3I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 12:29:08 -0500
In-Reply-To: <20120207145120.26905922@destiny.ordissimo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Anisse Astier <anisse@astier.eu>
Date: Tue, 7 Feb 2012 14:51:20 +0100

> On Tue, 07 Feb 2012 17:37:51 +0400, Pavel Emelyanov <xemul@parallels.=
com> wrote :
>=20
>> >> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
>> >> index 1a8f93b..43e1439 100644
>> >> --- a/net/ipv4/Kconfig
>> >> +++ b/net/ipv4/Kconfig
>> >> @@ -410,8 +410,12 @@ config INET_TCP_DIAG
>> >>  	def_tristate INET_DIAG
>> >> =20
>> >>  config INET_UDP_DIAG
>> >> +	tristate "UDP: socket monitoring interface"
>> >>  	depends on INET_DIAG
>> >> -	def_tristate INET_DIAG && IPV6
>> > This broke earlier patch=20
>> > b872a2371ffd13e6d83423ef621a707df4c158ac "udp_diag: Make it module=
 when ipv6 is a module",
>> > which brings back the compilation error when compiling linus maste=
r (v3.3-rc2+):
>> >=20
>> > net/built-in.o: In function `udp_dump_one':
>> > udp_diag.c:(.text+0x59852): undefined reference to `__udp6_lib_loo=
kup'
>> >=20
>> >=20
>> >> +	default n
>> >> +	---help---
>> >> +	  Support for UDP socket monitoring interface used by the ss to=
ol.
>> >> +	  If unsure, say Y.
>> >> =20
>>=20
>> I assume you have CONFIG_IPV6=3Dm and CONFIG_INET_UDP_DIAG=3Dy, righ=
t?
>=20
> That's correct.
>=20
>> This one should fix the issue, you'll not be able to set it to Y whe=
n
>> IPV6 is M.
>=20
> Indeed, it fixes the issue, but it also prevents using UDP_DIAG witho=
ut
> IPv6 (just like the previous patch I=A0guess.). Not a problem for me.

I don't think the previous code prevented udp_diag w/o ipv6, and requir=
ing
ipv6 for udp_diag is not acceptable so this patch needs to be updated t=
o
allow that.

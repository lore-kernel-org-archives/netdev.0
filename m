From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: use after free bug in socket code
Date: Tue, 14 Jul 2009 16:41:18 +0200
Message-ID: <4A5C990E.3080703@hartkopp.net>
References: <19028.16049.907160.45293@ipc1.ka-ro>	<20090709154533.GA27413@gondor.apana.org.au>	<19035.23045.386506.297464@ipc1.ka-ro>	<4A5B730B.8090902@hartkopp.net> <19036.9400.263297.330963@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	netdev@vger.kernel.org, urs.thuermann@volkswagen.de,
	Urs Thuermann <urs@isnogud.escape.de>
To: =?ISO-8859-1?Q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:58652 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753815AbZGNOl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 10:41:29 -0400
In-Reply-To: <19036.9400.263297.330963@ipc1.ka-ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lothar Wa=DFmann wrote:
> Oliver Hartkopp writes:
>>
>> Would you like to prepare a proper patch and post it on netdev?
>>
> I'll do.

=46ine.

> I would also submit a second patch to add an appropriate MODULE_ALIAS
> to the protocol drivers, so they can be autoloaded when compiled as
> module:
> diff -ur linux-2.6.30/net/can/bcm.c linux-2.6.30-karo/net/can/bcm.c
> --- linux-2.6.30/net/can/bcm.c	2009-06-10 05:05:27.000000000 +0200
> +++ linux-2.6.30-karo/net/can/bcm.c	2009-07-12 20:12:38.000000000 +02=
00
> @@ -75,6 +75,7 @@
>  MODULE_DESCRIPTION("PF_CAN broadcast manager protocol");
>  MODULE_LICENSE("Dual BSD/GPL");
>  MODULE_AUTHOR("Oliver Hartkopp <oliver.hartkopp@volkswagen.de>");
> +MODULE_ALIAS("can-proto-2");
> =20
>  /* easy access to can_frame payload */
>  static inline u64 GET_U64(const struct can_frame *cp)
> diff -ur linux-2.6.30/net/can/raw.c linux-2.6.30-karo/net/can/raw.c
> --- linux-2.6.30/net/can/raw.c	2009-06-10 05:05:27.000000000 +0200
> +++ linux-2.6.30-karo/net/can/raw.c	2009-07-12 20:12:29.000000000 +02=
00
> @@ -62,6 +62,7 @@
>  MODULE_DESCRIPTION("PF_CAN raw protocol");
>  MODULE_LICENSE("Dual BSD/GPL");
>  MODULE_AUTHOR("Urs Thuermann <urs.thuermann@volkswagen.de>");
> +MODULE_ALIAS("can-proto-1");
> =20
>  #define MASK_ALL 0
> =20

Good idea.

I currently added these aliases somewhere in my /etc/modprobe.d directo=
ry. But
if this can be done by the kernel itself, we can reduce the distro-depe=
nded
configuation effort.

You can add my

Acked-by: Oliver Hartkopp <oliver@hartkopp.net>

to both discussed patches directly.

>=20
>> ps. This code section was stable for more than three years now. Can =
you tell
>> me, how you kicked your system to run into this problem?
>>
> I was working on a chip driver for the i.MX25 flexcan controller. The
> bug was visible due to CONFIG_DEBUG_SLAB=3Dy which makes sure that
> memory is poisoned with a special pattern upon being freed.

Nice hint! I will enable this in my config also.

>=20
> The situation where this triggers a bug is when the chip driver's
> hard_start_xmit function returns a NETDEV_TX_BUSY and subsequently th=
e
> can interface is deconfigured.
>=20
> Maybe you could try this on different hardware?

Will do when i'm back at work ;-)

Many Thanks,
Oliver

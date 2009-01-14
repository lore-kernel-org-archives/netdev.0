From: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Subject: Re: [PATCH] Add init_dummy_netdev() and fix EMAC driver using it
Date: Wed, 14 Jan 2009 11:00:05 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0901141057110.31703@vixen.sonytel.be>
References: <1231906495.22571.79.camel@pasglop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vervifontaine.sonytel.be ([80.88.33.193]:62510 "EHLO
	vervifontaine.sonycom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757509AbZANKAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 05:00:08 -0500
In-Reply-To: <1231906495.22571.79.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Jan 2009, Benjamin Herrenschmidt wrote:
> This adds an init_dummy_netdev() function that gets a network device
> structure (allocation and lifetime entirely under caller's control) a=
nd
> initialize the minimum amount of fields so it can be used to schedule
> NAPI polls without registering a full blown interface. This is to be
> used by drivers that need to tie several hardware interfaces to a sin=
gle
> NAPI poll scheduler due to HW limitations.
>=20
> It also updates the ibm_newemac driver to use that, this fixing the
> oops on 2.6.29 due to passing NULL as "dev" to netif_napi_add()
>=20
> Symbol is exported GPL only a I don't think we want binary drivers do=
ing
> that sort of acrobatics (if we want them at all).
>=20
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Thanks, this fixed my Sequoia!

Tested-by: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>

> --- linux-work.orig/include/linux/netdevice.h	2009-01-13 16:13:41.000=
000000 +1100
> +++ linux-work/include/linux/netdevice.h	2009-01-14 14:13:24.00000000=
0 +1100
> @@ -4434,6 +4434,45 @@ err_uninit:
>  }
> =20
>  /**
> + *	init_dummy_netdev	- init a dummy network device for NAPI
> + *	@dev: device to init
> + *
> + *	This takes a network device structure and initialize the minimum
                                                  ^^^^^^^^^^
						  initializes
> + *	amount of fields so it can be used to schedule NAPI polls without
> + *	registering a full blown interface. This is to be used by drivers
> + *	that need to tie several hardware interfaces to a single NAPI
> + *	poll scheduler due to HW limitations.
> + */
> +int init_dummy_netdev(struct net_device *dev)
> +{
> +	/* Clear everything. Note we don't initialize spinlocks
> +	 * are they aren't supposed to be taken by any of the
           ^^^
	   as
> +	 * NAPI code and this dummy netdev is supposed to be
> +	 * only ever used for NAPI polls
> +	 */

With kind regards,

Geert Uytterhoeven
Software Architect

Sony Techsoft Centre Europe
The Corporate Village =C2=B7 Da Vincilaan 7-D1 =C2=B7 B-1935 Zaventem =C2=
=B7 Belgium

Phone:    +32 (0)2 700 8453
=46ax:      +32 (0)2 700 8622
E-mail:   Geert.Uytterhoeven@sonycom.com
Internet: http://www.sony-europe.com/

A division of Sony Europe (Belgium) N.V.
VAT BE 0413.825.160 =C2=B7 RPR Brussels
=46ortis =C2=B7 BIC GEBABEBB =C2=B7 IBAN BE41293037680010

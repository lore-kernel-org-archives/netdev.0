From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH 4/7] can/at91: don't check platform_get_irq's return	value
 against zero
Date: Wed, 16 Dec 2009 19:57:45 +0100
Message-ID: <4B292DA9.8040009@grandegger.com>
References: <1260979809-24811-1-git-send-email-u.kleine-koenig@pengutronix.de> <1260979809-24811-2-git-send-email-u.kleine-koenig@pengutronix.de> <1260979809-24811-3-git-send-email-u.kleine-koenig@pengutronix.de> <1260979809-24811-4-git-send-email-u.kleine-koenig@pengutronix.de> <4B290A57.3010705@grandegger.com> <20091216170802.GA26325@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, David Vrabel <dvrabel@arcom.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Kurt Van Dijck <kurt.van.dijck@eia.be>,
	netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:50030 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762844AbZLPS6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 13:58:41 -0500
In-Reply-To: <20091216170802.GA26325@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Uwe Kleine-K=F6nig wrote:
> On Wed, Dec 16, 2009 at 05:27:03PM +0100, Wolfgang Grandegger wrote:
>> Uwe Kleine-K=F6nig wrote:
>>> platform_get_irq returns -ENXIO on failure, so !irq was probably
>>> always true.  Better use (int)irq <=3D 0.  Note that a return value=
 of
>>> zero is still handled as error even though this could mean irq0.
>> But only on ARM, which is the only platform still using the infamous
>> NO_IRQ (=3D-1). As this is a driver for ARM hardware, using irq =3D=3D=
 NO_IRQ
>> would make sense, though.
>=20
> This has nothing to do with NO_IRQ.  You could do:

Right, sorry for the noise.

> -       if (!res || !irq) {
> +       if (!res || irq <=3D (int)NO_IRQ) {
>=20
> but this looks too ugly.  (IMHO using NO_IRQ is already ugly.)
>=20
> Still, before my patch platform_get_irq return 0 was an error and if
> this should be handled as irq0 this is a separate issue that should b=
e
> fixed in a separate patch.

"irq <=3D 0" seems then the best solution. Will add my signed-off-by to
the patch.

Thanks,

Wolfgang.

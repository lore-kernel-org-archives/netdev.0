From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH 4/7] can/at91: don't check platform_get_irq's return
	value against zero
Date: Wed, 16 Dec 2009 18:08:03 +0100
Message-ID: <20091216170802.GA26325@pengutronix.de>
References: <1260979809-24811-1-git-send-email-u.kleine-koenig@pengutronix.de> <1260979809-24811-2-git-send-email-u.kleine-koenig@pengutronix.de> <1260979809-24811-3-git-send-email-u.kleine-koenig@pengutronix.de> <1260979809-24811-4-git-send-email-u.kleine-koenig@pengutronix.de> <4B290A57.3010705@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, David Vrabel <dvrabel@arcom.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Kurt Van Dijck <kurt.van.dijck@eia.be>,
	netdev@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:50505 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762372AbZLPRIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 12:08:09 -0500
Content-Disposition: inline
In-Reply-To: <4B290A57.3010705@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 16, 2009 at 05:27:03PM +0100, Wolfgang Grandegger wrote:
> Uwe Kleine-K=F6nig wrote:
> > platform_get_irq returns -ENXIO on failure, so !irq was probably
> > always true.  Better use (int)irq <=3D 0.  Note that a return value=
 of
> > zero is still handled as error even though this could mean irq0.
>=20
> But only on ARM, which is the only platform still using the infamous
> NO_IRQ (=3D-1). As this is a driver for ARM hardware, using irq =3D=3D=
 NO_IRQ
> would make sense, though.

This has nothing to do with NO_IRQ.  You could do:

-       if (!res || !irq) {
+       if (!res || irq <=3D (int)NO_IRQ) {

but this looks too ugly.  (IMHO using NO_IRQ is already ugly.)

Still, before my patch platform_get_irq return 0 was an error and if
this should be handled as irq0 this is a separate issue that should be
fixed in a separate patch.

Best regards
Uwe

PS:

linux-2.6$ git grep -E 'define *NO_IRQ\>' arch/*/include
arch/arm/include/asm/irq.h:#define NO_IRQ       ((unsigned int)(-1))
arch/microblaze/include/asm/irq.h:#define NO_IRQ (-1)
arch/mn10300/include/asm/irq.h:#define NO_IRQ           INT_MAX
arch/parisc/include/asm/irq.h:#define NO_IRQ            (-1)
arch/powerpc/include/asm/irq.h:#define NO_IRQ                   (0)


--=20
Pengutronix e.K.                              | Uwe Kleine-K=F6nig     =
       |
Industrial Linux Solutions                    | http://www.pengutronix.=
de/  |

From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] net/fec: Don't let ndo_start_xmit return NETDEV_TX_BUSY
 without link
Date: Wed, 31 Jul 2013 10:16:49 +0200
Message-ID: <20130731081649.GA1754@pengutronix.de>
References: <1374758875-7926-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <1375176580-7368-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <20130730.160530.831845971567683172.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, fabio.estevam@freescale.com,
	Frank.Li@freescale.com, shawn.guo@linaro.org,
	kernel@pengutronix.de, hector.palacios@digi.com,
	tim.sander@hbm.com, rostedt@goodmis.org, tglx@linutronix.de,
	stephen@networkplumber.org, B38611@freescale.com,
	florian@openwrt.org, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60795 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759223Ab3GaIRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 04:17:04 -0400
Content-Disposition: inline
In-Reply-To: <20130730.160530.831845971567683172.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 30, 2013 at 04:05:30PM -0700, David Miller wrote:
> From: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> Date: Tue, 30 Jul 2013 11:29:40 +0200
>=20
> > Don't test for having link and let hardware deal with this situatio=
n.
> >=20
> > Without this patch I see a machine running an -rt patched Linux bei=
ng
> > stuck in sch_direct_xmit when it looses link while there is still a
> > packet to be sent. In this case the fec_enet_start_xmit routine ret=
urned
> > NETDEV_TX_BUSY which makes the network stack reschedule the packet =
and
> > so sch_direct_xmit calls fec_enet_start_xmit again.
> > I failed to reproduce a complete hang without -rt, but I think the
> > problem exists there, too.
> >=20
> > Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
>=20
> Applied, thanks.
Thanks, I see it as a264b981f2c76e281ef27e7232774bf6c54ec865 in net.git
(i.e.
https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=3D=
a264b981f2c76e281ef27e7232774bf6c54ec865)

You missed to take the

	Acked-and-tested-by: Fugang Duan <B38611@freescale.com>

=2E If you want to fix that, you can do:

	git filter-branch --msg-filter 'if test $GIT_COMMIT =3D a264b981f2c76e=
281ef27e7232774bf6c54ec865; then sed "/David/ i Acked-and-tested-by: Fu=
gang Duan <B38611@freescale.com>"; else cat; fi' a264b981f2c76e281^..

on your master branch to add it to that commit.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |

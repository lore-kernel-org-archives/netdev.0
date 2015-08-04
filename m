From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] net: fec: fix initial runtime PM refcount
Date: Tue, 4 Aug 2015 10:11:40 +0200
Message-ID: <20150804081140.GH9999@pengutronix.de>
References: <1438617011-19073-1-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	patchwork-lst@pengutronix.de, kernel@pengutronix.de
To: Lucas Stach <l.stach@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60254 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754698AbbHDILn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 04:11:43 -0400
Content-Disposition: inline
In-Reply-To: <1438617011-19073-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Lucas,

On Mon, Aug 03, 2015 at 05:50:11PM +0200, Lucas Stach wrote:
> The clocks are initially active and thus the device is marked active.
> This still keeps the PM refcount at 0, the pm_runtime_put_autosuspend=
()
> call at the end of probe then leaves us with an invalid refcount of -=
1,
> which in turn leads to the device staying in suspended state even tho=
ugh
> netdev open had been called.
>=20
> Fix this by initializing the refcount to be coherent with the initial
> device status.
>=20
> Fixes:
> 8fff755e9f8 (net: fec: Ensure clocks are enabled while using mdio bus=
)
>=20
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
the two \n after "Fixes:" and before the S-o-b are unusual I think.

Other than that I tested the change on i.MX27 and it works now. The
power refcount oscillates between 1 and 2 now as expected and booting
with NFS-root works fine. So:

Tested-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Thanks
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |

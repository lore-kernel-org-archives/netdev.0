From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v2 06/10] ARM: mx28: update clocks for dual fec support
Date: Tue, 4 Jan 2011 14:58:18 +0100
Message-ID: <20110104135818.GD25121@pengutronix.de>
References: <1294133056-21195-1-git-send-email-shawn.guo@freescale.com> <1294133056-21195-7-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, gerg@snapgear.com, baruch@tkos.co.il,
	eric@eukrea.com, bryan.wu@canonical.com, r64343@freescale.com,
	B32542@freescale.com, lw@karo-electronics.de,
	w.sang@pengutronix.de, s.hauer@pengutronix.de,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34378 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482Ab1ADN6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 08:58:39 -0500
Content-Disposition: inline
In-Reply-To: <1294133056-21195-7-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Shawn,

On Tue, Jan 04, 2011 at 05:24:12PM +0800, Shawn Guo wrote:
> Register clocks fec.0 and fec.1 for dual fec support.
>=20
> Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
> ---
> Changes for v2:
>  - Rebase the patch against patch below which gets fundamental
>    clocks explicitly called in clk_enable.
>    [PATCH v4] ARM: mxs: Change duart device to use amba-pl011
>  - Register clocks fec.0 and fec.1 respectively than use wildcard
>    NULL for both instances.
>=20
>  arch/arm/mach-mxs/clock-mx28.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/arch/arm/mach-mxs/clock-mx28.c b/arch/arm/mach-mxs/clock=
-mx28.c
> index f20b254..f79587b 100644
> --- a/arch/arm/mach-mxs/clock-mx28.c
> +++ b/arch/arm/mach-mxs/clock-mx28.c
> @@ -607,6 +607,7 @@ static struct clk_lookup lookups[] =3D {
>  	/* for amba-pl011 driver */
>  	_REGISTER_CLOCK("duart", NULL, uart_clk)
>  	_REGISTER_CLOCK("fec.0", NULL, fec_clk)
> +	_REGISTER_CLOCK("fec.1", NULL, fec_clk)
Did you verify this works as intended?  I didn't and consider it
possible that after

	clk_enable("fec.0");
	clk_enable("fec.1");
	clk_disable("fec.1");

the clk is off.  Probably it just works, just want to prevent hard to
find bugs ...

Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |

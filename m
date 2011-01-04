From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH v2 06/10] ARM: mx28: update clocks for dual fec support
Date: Tue, 4 Jan 2011 22:26:44 +0800
Message-ID: <20110104142643.GB21274@freescale.com>
References: <1294133056-21195-1-git-send-email-shawn.guo@freescale.com>
 <1294133056-21195-7-git-send-email-shawn.guo@freescale.com>
 <20110104135818.GD25121@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<lw@karo-electronics.de>, <w.sang@pengutronix.de>,
	<s.hauer@pengutronix.de>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:9802 "EHLO
	TX2EHSOBE008.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028Ab1ADOZL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 09:25:11 -0500
Received: from mail161-tx2 (localhost.localdomain [127.0.0.1])	by
 mail161-tx2-R.bigfish.com (Postfix) with ESMTP id A6801A3840D	for
 <netdev@vger.kernel.org>; Tue,  4 Jan 2011 14:25:10 +0000 (UTC)
Received: from TX2EHSMHS009.bigfish.com (unknown [10.9.14.253])	by
 mail161-tx2.bigfish.com (Postfix) with ESMTP id B369C740171	for
 <netdev@vger.kernel.org>; Tue,  4 Jan 2011 14:24:39 +0000 (UTC)
Received: from az33smr02.freescale.net (az33smr02.freescale.net
 [10.64.34.200])	by de01egw01.freescale.net (8.14.3/8.14.3) with ESMTP id
 p04EObU8024628	for <netdev@vger.kernel.org>; Tue, 4 Jan 2011 07:24:37 -0700
 (MST)
Received: from ubuntu.localdomain (ubuntu-010192242196.ap.freescale.net
 [10.192.242.196])	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id
 p04EOact014765	for <netdev@vger.kernel.org>; Tue, 4 Jan 2011 08:24:36 -0600
 (CST)
Content-Disposition: inline
In-Reply-To: <20110104135818.GD25121@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Uwe,

On Tue, Jan 04, 2011 at 02:58:18PM +0100, Uwe Kleine-K=F6nig wrote:
> Hello Shawn,
>=20
> On Tue, Jan 04, 2011 at 05:24:12PM +0800, Shawn Guo wrote:
> > Register clocks fec.0 and fec.1 for dual fec support.
> >=20
> > Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
> > ---
> > Changes for v2:
> >  - Rebase the patch against patch below which gets fundamental
> >    clocks explicitly called in clk_enable.
> >    [PATCH v4] ARM: mxs: Change duart device to use amba-pl011
> >  - Register clocks fec.0 and fec.1 respectively than use wildcard
> >    NULL for both instances.
> >=20
> >  arch/arm/mach-mxs/clock-mx28.c |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/arch/arm/mach-mxs/clock-mx28.c b/arch/arm/mach-mxs/clo=
ck-mx28.c
> > index f20b254..f79587b 100644
> > --- a/arch/arm/mach-mxs/clock-mx28.c
> > +++ b/arch/arm/mach-mxs/clock-mx28.c
> > @@ -607,6 +607,7 @@ static struct clk_lookup lookups[] =3D {
> >  	/* for amba-pl011 driver */
> >  	_REGISTER_CLOCK("duart", NULL, uart_clk)
> >  	_REGISTER_CLOCK("fec.0", NULL, fec_clk)
> > +	_REGISTER_CLOCK("fec.1", NULL, fec_clk)
> Did you verify this works as intended?  I didn't and consider it
> possible that after
>=20
> 	clk_enable("fec.0");
> 	clk_enable("fec.1");
> 	clk_disable("fec.1");
>=20
> the clk is off.  Probably it just works, just want to prevent hard to
> find bugs ...
>=20
The clk should not be off.  Looking at _REGISTER_CLOCK below, we are
registering both fec.0 and fec.1 on the same one fec_clk.  IOW, the
usecount of the clk is working to control the on/off of the clk.

#define _REGISTER_CLOCK(d, n, c) \
	{ \
		.dev_id =3D d, \
		.con_id =3D n, \
		.clk =3D &c, \
	},

--=20
Regards,
Shawn


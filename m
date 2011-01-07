From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v3 05/10] net/fec: add dual fec support for mx28
Date: Fri, 7 Jan 2011 10:44:49 +0100
Message-ID: <20110107094448.GB25121@pengutronix.de>
References: <1294236457-17476-1-git-send-email-shawn.guo@freescale.com> <1294236457-17476-6-git-send-email-shawn.guo@freescale.com> <20110105163449.GU25121@pengutronix.de> <20110106041457.GC17891@freescale.com> <20110106071047.GW25121@pengutronix.de> <20110107070056.GA28358@freescale.com>
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
Received: from metis.ext.pengutronix.de ([92.198.50.35]:51675 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754294Ab1AGJpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jan 2011 04:45:14 -0500
Content-Disposition: inline
In-Reply-To: <20110107070056.GA28358@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Fri, Jan 07, 2011 at 03:00:57PM +0800, Shawn Guo wrote:
> On Thu, Jan 06, 2011 at 08:10:47AM +0100, Uwe Kleine-K=F6nig wrote:
> > Hello Shawn,
> >=20
> [...]
> > > > > +     /*
> > > > > +      * enet-mac reset will reset mac address registers too,
> > > > > +      * so need to reconfigure it.
> > > > > +      */
> > > > > +     if (fec_is_enetmac) {
> > > > > +             memcpy(&temp_mac, dev->dev_addr, ETH_ALEN);
> > > 		  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> > > > > +             writel(cpu_to_be32(temp_mac[0]), fep->hwp + FEC=
_ADDR_LOW);
> > > > > +             writel(cpu_to_be32(temp_mac[1]), fep->hwp + FEC=
_ADDR_HIGH);
> > > > where is the value saved to temp_mac[]?  For me it looks you wr=
ite
> > > > uninitialized data into the mac registers.
> > >=20
> > > memcpy above.
> > oops.  right.  I looked for something like
> >=20
> > 	temp_mac[0] =3D dev->dev_addr[0] << $shiftfor0 | ...
> >=20
> > which AFAIK is what you want here.  memcpy is sensible to (at least=
)
> > endian issues.  If you ask me factor out the setting of the mac add=
ress
> > in probe to a function and use that here, too.
> >=20
> The memcpy of mac address is being widely used in fec and other
> network drivers, and I do not prefer to change something so common
> in this patch set.
Hmm, fec_get_mac uses memcpy as does fec_set_mac_address.
fec_enet_init uses mask and shift.  When writing my comment I only saw
the latter.  Having that uniform and only in two places (one for settin=
g
and for reading) would be great.

Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |

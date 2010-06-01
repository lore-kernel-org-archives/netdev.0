From: Andy Fleming <afleming@gmail.com>
Subject: Re: [PATCH] phylib: Add support for the LXT973 phy.
Date: Tue, 1 Jun 2010 17:39:22 -0500
Message-ID: <AANLkTilKJVZiKLRUlL7AeaqSnlAs2u5sTW7o2vfvEKns@mail.gmail.com>
References: <20100531130932.GA15845@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:40005 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754605Ab0FAWjY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 18:39:24 -0400
Received: by ey-out-2122.google.com with SMTP id d26so283357eyd.19
        for <netdev@vger.kernel.org>; Tue, 01 Jun 2010 15:39:22 -0700 (PDT)
In-Reply-To: <20100531130932.GA15845@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 31, 2010 at 8:09 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> This patch implements a work around for Erratum 5, "3.3 V Fiber Speed
> Selection." If the hardware wiring does not respect this erratum, the=
n
> fiber optic mode will not work properly.
>
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>


>
> +static int lxt973_probe(struct phy_device *phydev)
> +{
> + =A0 =A0 =A0 int val =3D phy_read(phydev, MII_LXT973_PCR);
> +
> + =A0 =A0 =A0 if (val & PCR_FIBER_SELECT) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If fiber is selected, then the onl=
y correct setting
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* is 100Mbps, full duplex, and auto =
negotiation off.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 val =3D phy_read(phydev, MII_BMCR);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 val |=3D (BMCR_SPEED100 | BMCR_FULLDPLX=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 val &=3D ~BMCR_ANENABLE;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_write(phydev, MII_BMCR, val);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Remember that the port is in fiber m=
ode. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phydev->priv =3D lxt973_probe;


That's a bit hacky.  There is a dev_flags field, which could be used
for this.  Probably, we should add a more general way of saying what
sort of port this is.  But don't use the presence and absence of
"priv", as it could one day get used for a different purpose, and this
seems like it would leave us open to strange bugs.

Also, is this erratum true for all lxt973 models, or is it fixed in
some revisions?


Andy

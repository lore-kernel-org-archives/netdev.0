From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC PATCH] net:Add basic DWC Ethernet QoS Driver
Date: Thu, 08 May 2014 16:26 +0200
Message-ID: <5261973.l3atPvULh6@wuerfel>
References: <201405081349.03139.Andreas.Irestal@axis.com> <20248221.mJ8pFfyc5U@wuerfel> <201405081618.04475.Andreas.Irestal@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"maxime.ripard@free-electrons.com" <maxime.ripard@free-electrons.com>,
	"abrodkin@synopsys.com" <abrodkin@synopsys.com>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"sr@denx.de" <sr@denx.de>,
	"jonas.jensen@gmail.com" <jonas.jensen@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Jesper Nilsson <jespern@axis.com>, peppe.cavallaro@st.com
To: Andreas =?ISO-8859-1?Q?Irest=E5l?= <andreas.irestal@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:55488 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbaEHO03 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 10:26:29 -0400
In-Reply-To: <201405081618.04475.Andreas.Irestal@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 08 May 2014 16:18:04 Andreas Irest=E5l wrote:
>=20
> > > +
> > > +   /* Set poll wait timeout to 2 seconds */
> > > +   dwc_wait =3D 200;
> > > +
> > > +   while (lp->tx_descs[i].tdes3.wr.own) {
> > > +           mdelay(10);
> > > +           if (!dwc_wait--)
> > > +                   break;
> > > +   }
> >=20
> > This is really evil: you are blocking the CPU for up to two seconds=
!
> > You already mentioned that this is work-in-progress, but I guess it=
 has
> > to be a little better than this and do something that doesn't block
> > out the CPU during TX.
> >=20
>=20
> It really is, but a 2s lockout is only happening upon TX failure. Any=
way, this
> won't be an issue in the final version, since it won't use polling fo=
r TX.

Actually I'd expect a 10ms delay for most packets, which is also too mu=
ch.

Just for scale: at gigabit speed, a 10 *microsecond* delay would be mor=
e
appropriate than a 10 milisecond delay. Anyway, it's not important here=
 as
long as you find a proper solution.

	Arnd

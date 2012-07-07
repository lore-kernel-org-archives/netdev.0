From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] smsc95xx: support ethtool get_regs
Date: Sat, 7 Jul 2012 20:55:59 +0100
Message-ID: <1341690959.25597.168.camel@deadeye.wl.decadent.org.uk>
References: <203906907.2074.1341669484945.JavaMail.root@mail.savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steve Glendinning <steve@shawell.net>,
	steve glendinning <steve.glendinning@smsc.com>,
	<netdev@vger.kernel.org>, Nancy Lin <nancy.lin@smsc.com>
To: =?ISO-8859-1?Q?=C9meric?= Vigier
	<emeric.vigier@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:48843 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751187Ab2GGT4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2012 15:56:04 -0400
In-Reply-To: <203906907.2074.1341669484945.JavaMail.root@mail.savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-07-07 at 09:58 -0400, =C3=89meric Vigier wrote:
[...]
> > > +	for (i =3D 0; i <=3D PHY_SPECIAL; i++)
> > > +		data[j++] =3D smsc95xx_mdio_read(netdev, dev->mii.phy_id, i);
> > > +}
> >=20
> > Again, why use PHY_SPECIAL (+ 1) here as opposed to 32 in the
> > calculation of the length?
>=20
> 32 was ok, but I hesitated between defining a SMSC95XX_PHY_END or usi=
ng the last defined register.
> Are 32 register-PHY generic to most devices? I mean could 32 be use w=
idely?

Yes, the address space for the original MDIO protocol ('clause 22')
allows for 32 registers.  Perhaps that number should be named in
<linux/mii.h>.

As another reviewer commented, though, MDIO PHY registers should be
accessible with SIOCGMIIREG and mii-tool so it's not really necessary t=
o
duplicate them here.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

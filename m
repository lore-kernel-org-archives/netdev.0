From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: mvneta: SGMII fixed-link not so fixed
Date: Fri, 18 Sep 2015 18:22:22 +0100
Message-ID: <20150918172222.GL21084@n2100.arm.linux.org.uk>
References: <20150917231422.GY21084@n2100.arm.linux.org.uk>
 <55FBF59E.3010205@list.ru>
 <20150918121311.GD21084@n2100.arm.linux.org.uk>
 <55FC070A.6020707@list.ru>
 <20150918131257.GF21084@n2100.arm.linux.org.uk>
 <55FC151F.6040708@list.ru>
 <20150918135746.GG21084@n2100.arm.linux.org.uk>
 <55FC2387.9080304@list.ru>
 <20150918154339.GJ21084@n2100.arm.linux.org.uk>
 <55FC35F9.9040403@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, andrew@lunn.ch,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:58743 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbbIRRWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 13:22:33 -0400
Content-Disposition: inline
In-Reply-To: <55FC35F9.9040403@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 18, 2015 at 07:04:09PM +0300, Stas Sergeev wrote:
> 18.09.2015 18:43, Russell King - ARM Linux =D0=BF=D0=B8=D1=88=D0=B5=D1=
=82:
> > On Fri, Sep 18, 2015 at 05:45:27PM +0300, Stas Sergeev wrote:
> >> AFAICS if it has use_inband_status=3D=3Dtrue,
> >> then it went through of_phy_register_fixed_link(dn),
> >=20
> > That's totally incorrect.  The test for setting use_inband_status i=
n
> > mvneta is:
> >=20
> >         err =3D of_property_read_string(dn, "managed", &managed);
> >         pp->use_inband_status =3D (err =3D=3D 0 &&
> >                                  strcmp(managed, "in-band-status") =
=3D=3D 0);
>=20
> Arrrr! I was looking at the branch without the last
> patch applied, so it occurred to me as
>=20
> 	pp->use_inband_status =3D (phy_mode =3D=3D PHY_INTERFACE_MODE_SGMII)=
 &&
> 		fixed_phy;
>=20
> Sorry for that.

Yay :)

> So we seem to indeed have a nasty regression with the patch
> that just went to stable. :( Great news.

Yes.

> Thanks for you time.
>=20
> I still have problems with this part though:
> > If there's neither a MDIO PHY nor a fixed-link, then the network dr=
iver
> > fails to initialise the device.
>=20
> I think I am looking into the right source this time, seems like
> if we don't have both but still have managed=3D"in-band-status", that
> should go the fixed-link path and still work... no?

If we have no fixed-link and no phy, then you're correct.

However, I really don't like the idea of abusing "fixed-link" as a
method to generate an ethtool/miitool/miidiag compatible output for
this, but I'm willing to let that pass for the moment. :)

--=20
=46TTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

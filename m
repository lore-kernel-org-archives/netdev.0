From: Stas Sergeev <stsp@list.ru>
Subject: Re: mvneta: SGMII fixed-link not so fixed
Date: Fri, 18 Sep 2015 14:29:34 +0300
Message-ID: <55FBF59E.3010205@list.ru>
References: <20150914103207.GH21084@n2100.arm.linux.org.uk>
 <55F6AA25.2070603@list.ru> <20150914114209.GL21084@n2100.arm.linux.org.uk>
 <20150917.151247.2129216999071943354.davem@davemloft.net>
 <20150917231422.GY21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andrew@lunn.ch, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp35.i.mail.ru ([94.100.177.95]:42310 "EHLO smtp35.i.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751190AbbIRL3k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Sep 2015 07:29:40 -0400
In-Reply-To: <20150917231422.GY21084@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

18.09.2015 02:14, Russell King - ARM Linux =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
> 3. Having DT specify a fixed-link with parameters along with in-band
>    negotiation results in the fixed-link parameters being ignored.
>    This means if a fixed-link DT declaration specifies a speed, that
>    declaration will be ignored.  What I'm basically saying is that:
>=20
> 		phy-mode =3D "sgmii";
> 		fixed-link {
> 			speed =3D <1000>;
> 		};
>=20
>    specifies a fixed-speed serdes link at 1000mbps, but:
>=20
> 		phy-mode =3D "sgmii";
> 		managed =3D "in-band-status";
> 		fixed-link {
> 			speed =3D <1000>;
> 		};
>=20
>    does not fix the speed at all.
I think the fixed-link DT parsing should be moved from of_mdio.c
to fixed-phy.c. Then fixed-phy will be able to back up the initial
values and use them whenever needed.
I can even do such a simple patch, but since it is not strictly
speaking a regression from my changes, I'd rather prefer someone
else do. :)


>  _But_ using the in-band status
>    property fundamentally requires this for mvneta to behave correctl=
y:
>=20
> 		phy-mode =3D "sgmii";
> 		managed =3D "in-band-status";
> 		fixed-link {
> 		};
>=20
>    with _no_ phy node.
I don't understand this one.
At least for me it works without empty fixed-link.
There may be some bug.

>=20
> 4. Going back to the SFP problem, the link is only up when the SFP
>    module pins indicate that there's no transmitter fault, no loss of
>    signal _and_ the PCS layer at the MAC indicates that it has comple=
ted
>    negotiation.  This pretty much rules out trying to emulate a SFP c=
age
>    as a software-based PHY.  I've code right now doing exactly that, =
and
>    it results in netif_carrier_on() being called far too early.
>=20
> What I don't know is how many generations of the mvneta hardware have
> support for both serdes modes, but what I'm basically saying is that
> the solution we now have seems to be somewhat lacking - maybe it shou=
ld
> have been "auto", "in-band-sgmii" and "in-band-1000base-x" with the
> ability to add additional modes later.
Well, you need to be quick with such a change, esp now when the patch
was queued to -stable.
What alternatives do we have here?
Will the following work too?
 		phy-mode =3D "1000base-x";
 		managed =3D "in-band-status";

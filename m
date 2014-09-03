From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v4 1/4] ethernet: arc: Add support for Rockchip SoC layer device tree bindings
Date: Wed, 03 Sep 2014 14:50:22 +0200
Message-ID: <3545574.7Z5WmaTlg0@wuerfel>
References: <1409740036-8117-1-git-send-email-romain.perier@gmail.com> <3774938.44qiV4hEoE@wuerfel> <12261801.xhz3LcucGs@diego>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org,
	Romain Perier <romain.perier@gmail.com>,
	linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
	netdev@vger.kernel.org
To: Heiko =?ISO-8859-1?Q?St=FCbner?= <heiko@sntech.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:53159 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932573AbaICMvE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 08:51:04 -0400
In-Reply-To: <12261801.xhz3LcucGs@diego>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 03 September 2014 14:20:50 Heiko St=FCbner wrote:
> >=20
> > One last question: is this the location given as .grf_offset the
> > only thing in grf that is potentially of concern to this driver?
> >=20
> > If it is, you can change the binding to include the register number
> > in the syscon reference, like
> >=20
> >       rockchip,grf =3D <&grf 0x154>;
> >=20
> > and then read it from there, to simplify the code needed to get the
> > number from the device id.
>=20
> I would disagree here=20
>=20
> Specific to the emac, there also exists a second register in the grf =
(0xa8 for=20
> the rk3188) that contains a field=20
>=20
> ----
> emac_newrcv_en - the selection of RMII receive selection
> 0: don't support the data package without header
> 1: support the data package without header
> ----
>=20
> which we don't handle currently but somebody might want to in the fut=
ure.
> [There also is no documentation of this at all]

Ok, fair enough. If there is a chance that there would be more of these
fields that we may want to support in the future, the table approach
seems reasonable.

The main advantage of putting the register number into the syscon
reference is to support future models without driver changes, but
it's not clear if that's worth it.

	Arnd

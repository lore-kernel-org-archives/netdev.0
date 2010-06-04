From: Phil Sutter <phil@nwl.cc>
Subject: Re: still having r8169 woes with XID 18000000
Date: Fri, 4 Jun 2010 15:43:44 +0200
Message-ID: <20100604134351.7981F4CD45@orbit.nwl.cc>
References: <4C08ED47.1030800@iki.fi> <20100604123641.ED8154CD45@orbit.nwl.cc> <4C08F953.1050800@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?utf-8?B?ZnJhbsOnb2lz?= romieu <romieu@fr.zoreil.com>
To: Timo =?utf-8?B?VGVyw6Rz?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:45578 "EHLO orbit.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755696Ab0FDNnw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jun 2010 09:43:52 -0400
Content-Disposition: inline
In-Reply-To: <4C08F953.1050800@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Jun 04, 2010 at 04:02:11PM +0300, Timo Ter=C3=A4s wrote:
> > Comparing r8169-6.013 with it's predecessor 6.012, you'll find a ne=
wly
> > enabled function rtl8169_phy_power_up() as well as some more invoca=
tions
> > of rtl8169_phy_power_down().
> >=20
> > This is probably the solution to these (at least in our case) very
> > sporadic, but highly annoying, problems. In fact, when our NIC didn=
't
> > detect any link, it needed a full power-cycle (no success with
> > reset-button), so almost not workaroundable.
>=20
> Sounds very similar to the problem I have. Thanks for the pointers!
>=20
> It looks like the r8169 driver does have phy power up code in it, but
> it's only executed for specific versions of the chip. Realtek driver
> seems to do it unconditionally.

Hmm. I actually never looked at the corresponding parts of the
in-tree-driver, but that would have definitely been the next step in
order to fix it.

> The check seems to be:
>                 if ((tp->mac_version =3D=3D RTL_GIGA_MAC_VER_11) ||
>                     (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_12) ||
>                     (tp->mac_version >=3D RTL_GIGA_MAC_VER_17)) {
>=20
> I wonder if I should just add my mac version there (_VER_05) and test=
 if
> it'll make it better.

Surely worth a try. On the other hand, looking at the sheer mass of
problem reports regarding this driver, making it worse is rather hard t=
o
do I guess. :)

(Good night and) good luck, Phil


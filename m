From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: stmmac-socfpga breakage in arm-soc
Date: Fri, 21 Mar 2014 18:51:17 +0100
Message-ID: <201403211851.17955.arnd@arndb.de>
References: <201403191333.01095.arnd@arndb.de> <29079107.ja9Hu9mMY0@wuerfel> <5329CA2A.8030309@elopez.com.ar>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dinh Nguyen <dinh.linux@gmail.com>,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hans de Goede <hdegoede@redhat.com>, arm@kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>,
	Dinh Nguyen <dinguyen@altera.com>
To: Emilio =?iso-8859-1?q?L=F3pez?= <emilio@elopez.com.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:56099 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733AbaCURv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 13:51:59 -0400
In-Reply-To: <5329CA2A.8030309@elopez.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 19 March 2014, Emilio L=F3pez wrote:
> El 19/03/14 11:58, Arnd Bergmann escribi=F3:
> (snip)
> > diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Doc=
umentation/devicetree/bindings/net/stmmac.txt
> > index 5748351..19d5648 100644
> > --- a/Documentation/devicetree/bindings/net/stmmac.txt
> > +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> > @@ -31,6 +31,10 @@ Optional properties:
> >   - reset-names: Should contain the reset signal name "stmmaceth", =
if a
> >       reset phandle is given
> >   - max-frame-size: See ethernet.txt file in the same directory
> > +- clocks: If present, the first clock should be the GMAC main cloc=
k,
> > +  further clocks may be specified in derived bindings
> > +- clock-names: One name for each entry in the clocks property, the
> > +  first one should be "stmmaceth".
> >
> >   Examples:
> >
> > @@ -43,4 +47,6 @@ Examples:
> >               mac-address =3D [000000000000]; /* Filled in by U-Boo=
t */
> >               max-frame-size =3D <3800>;
> >               phy-mode =3D "gmii";
> > +             clocks =3D <&clock>;
> > +             clock-names =3D "stmmaceth">
>=20
> There's a small typo there on the ;

=46ixed the typo locally. However, now we have another problem: I tried
to apply the update patch to arm-soc and found that I originally based
it on linux-next, which has a number of conflicting changes that are
not in arm-soc.

It's probably better if I remove the driver entirely from the arm-soc
tree and instead send the modified version to David Miller for him
to put it into the net tree.

	Arnd

From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC v2] mac80211: disallow bridging managed/adhoc interfaces
Date: Tue, 17 Nov 2009 23:46:45 +0100
Message-ID: <1258498005.30511.3.camel@johannes.local>
References: <1258465585.3682.7.camel@johannes.local>
	 <1258490898.21197.42.camel@johannes.local>
	 <646765f40911171442m467efbc8ped7abc9d529ed095@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-VP+zqB5ijd1Wo8y2Yors"
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Felix Fietkau <nbd@openwrt.org>
To: Julian Calaby <julian.calaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:33059 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756538AbZKQWrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 17:47:09 -0500
In-Reply-To: <646765f40911171442m467efbc8ped7abc9d529ed095@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-VP+zqB5ijd1Wo8y2Yors
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-11-18 at 09:42 +1100, Julian Calaby wrote:
> On Wed, Nov 18, 2009 at 07:48, Johannes Berg <johannes@sipsolutions.net> =
wrote:
> > --- wireless-testing.orig/net/mac80211/iface.c  2009-11-17 14:20:19.000=
000000 +0100
> > +++ wireless-testing/net/mac80211/iface.c       2009-11-17 17:56:08.000=
000000 +0100
> > @@ -745,6 +745,11 @@ int ieee80211_if_change_type(struct ieee
> >        if (type =3D=3D sdata->vif.type)
> >                return 0;
> >
> > +       /* if it's part of a bridge, reject changing type to station/ib=
ss */
> > +       if (sdata->dev->br_port && (type =3D=3D NL80211_IFTYPE_ADHOC ||
> > +                                   type =3D=3D NL80211_IFTYPE_STATION)=
)
> > +               return -EBUSY;
>=20
> Busy doesn't seem like the right error here ... maybe use -EOPNOTSUPP
> like the next test?

Not sure, it's a temporary error and you can fix it by removing it from
the bridge, so it's "busy" in the sense that it is fixed to the current
mode or any other bridging mode by being in the bridge ... it's not that
it doesn't support the mode.

johannes

--=-VP+zqB5ijd1Wo8y2Yors
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJLAyfSAAoJEODzc/N7+Qma8McP/RwWpszo+GBGcWAYraZSQ4QT
JIcMBY0Pw/ri5Um9A3V+OBxi/tccUIvdd9+XDklcrOHd4x4TBXpP2S6JHczjYB7q
iDxd8tYArYw1uH2wcSRjv75K1hXXm7VuComBPblajXf9eDnjSwlOkunYyPtRJPR7
rO244YdlJ8NFOGRCcVT7FIpM3Tr2nuhKVGjiCJTnJbJMAssZWAJ07fS8zTwzc9j4
81wV22wvi+us15QDSbPhPlLR/0p1eYMpSObniXiHHEMaNe79VcXZwY1lwBY/xlAv
hpUamcqknMLCXRc32SidIjnfiIgSIBkyCpdxwUTB6oeEKu9zbs0jSrnpjOfcDVSS
D/pdJq4Rid7Ia7XAqvKFAljo+DejHtRmxhu4yJcLy7nz6rvzjjssBdnKzhjkzyLX
hdbULdX1fl0BxqwcQ7kie6UXck1xyoMFuCsVRRLczsvvePMf5ccE8xFZ0K2j2YQM
BttuUBtqRDW/NQEPveDp3cLf5tONUKwNlTPkYsvFA9jD39D7Z0QiFjfDzi8UF2r1
0gms8MwY0QXtDOqS6SBx2AQtUWgyL4KMnBtnhTs/3SWbzZh6HbRhoRnJLPASriVh
Sr79lt9FITYvDupJxFnDUu2+Y/fWozQVT67YsUfCbHHwLtYShEQTTn+qSm/pBOpL
uwl7xgBfh5COFs9cRQD1
=QYw4
-----END PGP SIGNATURE-----

--=-VP+zqB5ijd1Wo8y2Yors--


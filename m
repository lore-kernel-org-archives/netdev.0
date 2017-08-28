From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] DSA support for Micrel KSZ8895
Date: Mon, 28 Aug 2017 08:47:12 +0200
Message-ID: <20170828064712.GB7721@amd>
References: <20170816075524.GA18532@amd>
 <20170816140451.GA13006@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
 <20170827123658.GA727@amd>
 <0D360298-6B3C-42BA-8E56-9F56E9B29BE4@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="vGgW1X5XWziG23Ko"
Cc: Woojung.Huh@microchip.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Tristram.Ha@micrel.com,
        andrew@lunn.ch
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0D360298-6B3C-42BA-8E56-9F56E9B29BE4@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--vGgW1X5XWziG23Ko
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> >No, tag_ksz part probably is not acceptable. Do you see solution
> >better than just copying it into tag_ksz1 file?
>=20
> You could have all Micrel tag implementations live under net/dsa/tag_ksz.=
c and have e.g: DSA_TAG_PROTO_KSZ for the current (newer) switches and DSA_=
TAG_PROTO_KSZ_LEGACY (or any other name) for the older switches and you wou=
ld provide two sets of function pointers depending on which protocol is req=
uested by the switch.
>=20
> Considering the minor difference needed in tagging here, it might be acce=
ptable to actually keep the current functions and just have the xmit() call=
 check what get_tag_protocol returns and use word 1 or 0 based on that. Eve=
n though that's a fast path it shouldn't hurt performance too much. If it d=
oes, we can always copy the tagging protocol into dsa_slave_priv so you hav=
e a fast access to it.
>=20

Actually I believe I can do optimizer tricks to keep this zero-cost
with clean code, if needed.

> >
> >Any more comments, etc?
>=20
> The MII emulation bits are interesting, was it not sufficient if you impl=
emented phy_read and phy_write operations that perform the necessary intern=
al PHY accesses or maybe you don't get access to standard MII registers? b5=
3 does such a thing and we merely just need to do a simple shift to access =
the MII register number, thus avoiding the translation.
>=20

We don't get standard MII registers over SPI bus.

> >Help would be welcome.
>=20
> I concur with Andrew, try to get a patch series, even an RFC one together=
 so we can review things individually.=20
>=20
> How functional is your driver so far? I'd say the basic stuff to get work=
ing: counters (debugging), link management (auto-negotiation, forced, etc.)=
 and basic bridging: all ports separate by default and working port to port=
 switching when brought together in a bridge. VLAN, FDB, MDB, other ethtool=
 goodies can be added later on.
>

Which counters are essential? Link management and basic bridging
should work, not sure if I'll have time to do more than that.

Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--vGgW1X5XWziG23Ko
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmjvHAACgkQMOfwapXb+vLq1QCgnmFAIjt7YyoFBJT1z7xQJajy
/8kAn2oPCkUrCD776dHF2i1ck9+Z5QKm
=/SIF
-----END PGP SIGNATURE-----

--vGgW1X5XWziG23Ko--

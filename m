From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: in kernel 2.6.x, tun/tap nic supports vlan packets
Date: Tue, 22 Apr 2014 18:53:57 +0100
Message-ID: <1398189237.7767.77.camel@deadeye.wl.decadent.org.uk>
References: <534F4C1E.1000006@gmail.com> <20140417050228.GC8243@1wt.eu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-EKrvnL+w9SpD0N48zO4a"
Cc: zhuyj <zyjzyj2000@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	joe@perches.com, julia.lawall@lip6.fr, dingtianhong@huawei.com,
	linux-kernel@vger.kernel.org, jasowang@redhat.com, mst@redhat.com,
	"Yang, Zhangle (Eric)" <Zhangle.Yang@windriver.com>,
	"Wu, Kuaikuai" <Kuaikuai.Wu@windriver.com>,
	"Tao, Yue" <Yue.Tao@windriver.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140417050228.GC8243@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-EKrvnL+w9SpD0N48zO4a
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-04-17 at 07:02 +0200, Willy Tarreau wrote:
> Hi Zhu,
>=20
> On Thu, Apr 17, 2014 at 11:35:58AM +0800, zhuyj wrote:
> > Hi, all
> >=20
> > In kernel 2.6.x, linux depends on nic vlan hardware acceleration to=20
> > insert/extract
> > vlan tag.

This is a gross overstatement.

The problem I know of is that prior to Linux 2.6.37 the RX path behaved
differently for VLAN-tagged packets depending on whether they were
extracted by the driver/hardware.

If you put a bridge (or bond) and VLAN device on top of a single
physical device that doesn't do VLAN tag extraction, the VLAN device
didn't get any packets because the bridge packet handler was called
first.  Whereas, if the driver called the 'VLAN accelerated' RX path,
the VLAN packet handler was called first.  (Linux 2.6.37 actually
standardised on the former behaviour, and 3.2 fixed it to be the
latter.)

I don't know whether that's the problem zhuyj has run into.

[...]
> Well, 2.6.32.x is in deep freeze mode and it receives only critical fixes
> once in a while. While I can appreciate that the patch above might solve
> the issue you're facing, I'm wondering if there are not any acceptable
> workarounds for such a deep freeze kernel. You patch is not huge,

I think it's huge by the standards of 2.6.32.y.

> but it
> definitely affects a working driver, and I wouldn't like risking to break
> the tap driver for other users, and I reall don't have the skills to audi=
t
> it completely to ensure this is not the case. And if it breaks, I'll have
> to revert it or seek for some help on netdev.
>=20
> So I'd say that I'd rather not merge it unless I get an Acked-by from som=
e
> netdev people who are willing to help in case of any future regression,
> which is unlikely but still possible.
[...]

For what it's worth, I would recommend against applying this.  I don't
think even Red Hat has backported the VLAN changes, and they have been
quite aggressive about backporting features to RHEL 6.

Ben.

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-EKrvnL+w9SpD0N48zO4a
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1astee/yOyVhhEJAQoFlhAAmYNy3LP5cfNP5uANfK24BqbKQTYFH5HK
TaMk77EzjAQ4R9vhLPjwgUt5ZVkYCsT+11Xp6D3jL/ioYwzfQRK6iPR1QO36sSbQ
ONQm9CT5wcWDgtxU3Db4QEpYbReTfus+7WFhvn4YT5GXeUc5UXu/uyrBjPyebCtZ
pcEq9BsWi0YfepzDwNM9q5m2Q7IVd4oxKTSlR0soumBhspZDqel+2oXJUWRxkOwm
Wimhv24rNIXPLTyGNbHlILqC3FCmjQtAw0mTj9NhAkjlr2g7qFN0iH7agrHSOCEX
1XBvQ/8hldiGyKB+dCKqA1ix11s761sIAKKeGHMwtxl3WjUdP5OI4js2NWmhs+dv
vujefL5lUlVEApTAHraJ9XZZeRP/t4o2aG3T4r8nH990wxxxy4jXHmr9HSwM2H1x
m6DYR9O1VhWX4xQHO7GvSncmkr2Kxl32mF/N9J763DrHChcDGTZGiTYAJ8zpv3lq
1eiUzlZQ/WP7KI4TwGfznKCDy8WMlhCa6CwNUlWRAnZDxjfMM3bBi6wMJkARHwss
/i4PoEndCy1EtXr44hqkwCBuf1FYuAMa3A8KRX7IL0cMlxV1W/A3FsxB4m2QrygS
0wwo/FXezs5awepCbLn3SFk1cSPg+eLdGES8iwwsFh/4cAGocGa8+4KCEPTMcDt0
onp7pKr+jpY=
=zDCF
-----END PGP SIGNATURE-----

--=-EKrvnL+w9SpD0N48zO4a--

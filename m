From: David Lamparter <equinox@diac24.net>
Subject: Re: mac addresses of local interfaces do not obey setageing 0
Date: Thu, 17 Feb 2011 10:56:07 +0100
Message-ID: <20110217095607.GA1739639@jupiter.n2.diac24.net>
References: <20110209181752.GA2042@darkmag.usersys.redhat.com>
 <20110215102538.5f24d62a@nehalam>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="1yeeQ81UyVL57Vl7"
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:38790 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752784Ab1BQJ42 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Feb 2011 04:56:28 -0500
Content-Disposition: inline
In-Reply-To: <20110215102538.5f24d62a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--1yeeQ81UyVL57Vl7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Feb 15, 2011 at 10:25:38AM -0800, Stephen Hemminger wrote:
> On Wed, 9 Feb 2011 19:17:52 +0100
> Veaceslav Falico <vfalico@redhat.com> wrote:
>=20
> > Hello,
> >=20
> > I have a host and a VM inside this host bridged. I've set ageing_time a=
nd
> > forward_delay to 0 and trying to capture all the traffic that goes thro=
ugh that
> > bridge from my VM, but it fails to capture the traffic that has dst eth=
er
> > address the same as the hosts address (i.e. I can't capture the traffic=
 to the
> > host).
> >=20
> > From the code, I see that br->ageing_time doesn't really work with loca=
l mac
> > addresses - has_expired() function never says that a local interface ma=
c address
> > is expired, because it verifies if fdb->is_static is set and returns ri=
ght away.
> >=20
> > Is this the desired behaviour? If so, is there a way to capture packets=
 with
> > destination to a local interface from another interface?
> >=20
> > I've also done a small patch and it seems to fix the situation, but I a=
m not
> > sure if it's the right way to do it.
>=20
> No.
> Local addresses should never age.
>=20
> The proper way to capture packet is to us AF_PACKET or tc actions.

If you really want to use a bridge for this kind of traffic capturing,
you can attach one side of a veth pair as third interface to the bridge,
clear off all the mac addresses (and have no higher-layer addresses on
the bridge either) and use the other side of the veth pair for your
host. Since the "far" side of the veth is not on the bridge, the bridge
will not treat its address any special.

(This is somewhat of a funny hack though. Use AF_PACKET really...)


-David


--1yeeQ81UyVL57Vl7
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iEYEARECAAYFAk1c8LcACgkQpfBGV6DCGYbD8gCfdPou+1n+noRNtwDGaevH7ita
M1sAnAnrbzQo6/mxc/4G64BCq0RCxcJX
=e4D+
-----END PGP SIGNATURE-----

--1yeeQ81UyVL57Vl7--

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: BUG: scheduling while atomic: ifconfig/0x00000002/4170
Date: Thu, 06 Sep 2007 17:19:55 +0200
Message-ID: <1189091995.28781.99.camel@johannes.berg>
References: <20070902184439.GA14306@paradigm.rfc822.org>
	 <6bffcb0e0709021659o3856cd06gabc054c949a84397@mail.gmail.com>
	 <alpine.LFD.0.999.0709060923340.26804@enigma.security.iitk.ac.in>
	 <20070906082301.GB21929@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-P0JM25PSs9MHCk1RoLrB"
Cc: Satyam Sharma <satyam-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Florian Lohoff <flo-BCn6idZOOBwdnm+yROfE0A@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Michal Piotrowski <michal.k.k.piotrowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070906082301.GB21929-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-P0JM25PSs9MHCk1RoLrB
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-09-06 at 16:23 +0800, Herbert Xu wrote:
> On Thu, Sep 06, 2007 at 10:32:33AM +0530, Satyam Sharma wrote:
> >=20
> > > > [  382.529041]  [<c02c8abc>] dev_close+0x24/0x67
> > > > [  382.529052]  [<e01f402b>] ieee80211_master_stop+0x4a/0x6d [mac80=
211]
>=20
> This is where the bug is.  You cannot call dev_close from an
> atomic context as i33380211_master_stop does it within spin
> locks.

Oh btw. Can we stick a might_sleep() into dev_close() *before* the test
whether the device is up? That way, we'd have seen the bug, but
apparently nobody before Florian ever did a 'ip link set wmaster0 down'
while the other interfaces were still open.

johannes

--=-P0JM25PSs9MHCk1RoLrB
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBG4Bqb/ETPhpq3jKURAodYAJ9Ue7BZ2OM/mODT3BxY5BZTViKo5gCgrEkC
LpH1f969DmQIZpNHoSH2Ank=
=vRYa
-----END PGP SIGNATURE-----

--=-P0JM25PSs9MHCk1RoLrB--

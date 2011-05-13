From: Noah Meyerhans <noahm@debian.org>
Subject: Re: [Bridge] Bug#625914: linux-image-2.6.38-2-amd64: bridging is
	not interacting well with multicast in 2.6.38-4
Date: Thu, 12 May 2011 22:03:02 -0700
Message-ID: <20110513050302.GR6397@morgul.net>
References: <20110506201234.6297.70279.reportbug@ip6-localhost> <1304995124.4065.157.camel@localhost> <20110510043833.GG6397@morgul.net> <1305031369.4065.259.camel@localhost> <20110510180540.GI6397@morgul.net> <20110510151100.52a9f8fa@nehalam> <20110510233540.GJ6397@morgul.net> <20110512164322.45626683@nehalam>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="4VWgGltm/5syTS5r"
Cc: Ben Hutchings <ben@decadent.org.uk>, 625914@bugs.debian.org,
	bridge@lists.linux-foundation.org, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minas.morgul.net ([128.31.0.48]:42409 "EHLO minas.morgul.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754082Ab1EMFDK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2011 01:03:10 -0400
Content-Disposition: inline
In-Reply-To: <20110512164322.45626683@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--4VWgGltm/5syTS5r
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 12, 2011 at 04:43:22PM -0700, Stephen Hemminger wrote:
> > > There were two more follow on commits in stable related to this.
> > > I recommend merging 2.6.38.6 which includes these.
> >=20
> > The problem still exists in the current 2.6.38.6.  Backing out 5f1c356a
> > still solves the problem there.
> >=20
> > I have not yet tried anything outside the stable-2.6.38.y tree, but it
> > seems like these same changes are present there, and it's unlikely that
> > other releases will work any better.
>=20
> Does this fix the problem?  The tap driver allocates an skb and throws
> it into the receive path, but the skb does not have the same padding
> as normal skb's received.
>=20
> --- a/drivers/net/tun.c	2011-05-12 16:36:15.231347935 -0700
> +++ b/drivers/net/tun.c	2011-05-12 16:36:38.503464573 -0700
> @@ -614,7 +614,7 @@ static __inline__ ssize_t tun_get_user(s
>  	}
> =20
>  	if ((tun->flags & TUN_TYPE_MASK) =3D=3D TUN_TAP_DEV) {
> -		align =3D NET_IP_ALIGN;
> +		align =3D NET_IP_ALIGN + NET_SKB_PAD;
>  		if (unlikely(len < ETH_HLEN ||
>  			     (gso.hdr_len && gso.hdr_len < ETH_HLEN)))
>  			return -EINVAL;
>=20

Sorry, this does not fix the problem.

noah


--4VWgGltm/5syTS5r
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQFNzLuFYrVLjBFATsMRAvl2AJ96D4N7aoFaaK4eWFGK3fZdXanXOwCffa50
BHxVatL3/uuk8H+dUrbKD7c=
=9EDh
-----END PGP SIGNATURE-----

--4VWgGltm/5syTS5r--

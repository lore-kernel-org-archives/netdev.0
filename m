From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net: clear iflink when moving to a new netns
Date: Wed, 12 Feb 2014 23:18:25 +0000
Message-ID: <1392247105.15615.41.camel@deadeye.wl.decadent.org.uk>
References: <1392162690-6647-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-AE/5geNfkk6Uyt5piPHa"
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52971 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752760AbaBLXSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 18:18:39 -0500
In-Reply-To: <1392162690-6647-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-AE/5geNfkk6Uyt5piPHa
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-02-11 at 15:51 -0800, Cong Wang wrote:
> From: Cong Wang <cwang@twopensource.com>
>=20
> BZ: https://bugzilla.kernel.org/show_bug.cgi?id=3D66691
>=20
> macvlan and vlan both use iflink to identify its lower device,
> however, after such device is moved to the new netns, its iflink
> would become meaningless as ifindex is per netns. So, instead of
> forbid them moving to another netns, just clear this field so that
> it will not be dumped at least.
[...]

And what if it's moved back into the same netns?

I think iflink should be changed to a net_device pointer, so it remains
valid for in-kernel users but rtnetlink can do the netns check before
revealing it to userland.

Ben.

--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-AE/5geNfkk6Uyt5piPHa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvwBQee/yOyVhhEJAQqP4RAAsnimQK/DEEiBe2EJAdpXsgGgG/QUMxmn
Tg1n2iLawT6653tigdVd59VROZiasXHJ0ryxYZL7lggOe8FntkIItuy67edD++tD
vr/tmGCl/YUfDGK6j5bbU6LZYNHIyk3vz4sslk/nNMyEin1WsFD0jhnr+mAURzWE
pwH4px/BGqz62fOPpBVdrdls+XS/VV4FHesjP12b9SrmeunInxGfNpM2vF1kbVyq
RNbMJxi3zyNdQknKiTZktV7n2baY19B5kj1GVxHsrnO9gELjBLIlHFF7bTIUM+2A
ctuXhsD98oJRhrC3MGhMLY97qlShQytnxQae6nhf9mhh0By/MDv+nIfw3HgpQlxS
+buj8wC0Bi2RtTKuod8osVrxSYZ4uJiCUvokTZTYFMOKBfjR5dpFwz0PhIGgcagX
SxcUkM2ctoSN8+zjAJEsxO8guWuLCOK6z53YTrbnQ+Cf6CuE8WykaScyghE5SVQ4
lhRWdlhXLN9vv9fA6R22cvH6a3HP+hkRGeVqUcfGe8013ubyFnHfV2/mFUX5zRIU
O250ilTjTA7tLBp5Tp9mzBlz/zsbCDHlpLldPjWqo74ScM9Ue3xJIcWvYqDa4K3s
xnMtsS+aWqn17ASYvjQ0OAwQHB4NNuVgSwrFCRafE5FkuHRHYytvbKQCMBBkPtM5
TnTpkWXUC0g=
=JMV3
-----END PGP SIGNATURE-----

--=-AE/5geNfkk6Uyt5piPHa--

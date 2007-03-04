From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: Recent wireless breakage (ipw2200, iwconfig, NetworkManager)
Date: Mon, 05 Mar 2007 00:39:24 +0100
Message-ID: <1173051564.6131.13.camel@johannes.berg>
References: <20070304220857.GH23311@waste.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Bdf9yS6/Qs+ddGU6eaEw"
Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070304220857.GH23311-1tnLUEbcrg3YtjvyW6yDsg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-Bdf9yS6/Qs+ddGU6eaEw
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

[adding linux-wireless to CC]

On Sun, 2007-03-04 at 16:08 -0600, Matt Mackall wrote:
> Recent kernels are having troubles with wireless for me. Two seemingly
> related problems:

I don't think they are related actually.

> a) NetworkManager seems oblivious to the existence of my IPW2200

This is due to the recent sysfs restructuring I think. IIRC the fix is
to upgrade hal to a current git version.

> b) Manual iwconfig waits for 60s and then reports:

That one's strange.

> A second attempt to enable WEP via iwconfig succeeds and network
> connectivity is normal. However, NetworkManager still ignores the
> device at this point.

I'd think it's a ipw bug but I have no idea if that was even touched
during this time.

> Bisect with Mercurial points to this patch:
>=20
> $ hg bisect bad
> The first bad revision is:
> changeset:   46985:f701b96bb2f7
> user:        Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
> date:        Wed Feb 07 10:37:11 2007 -0800
> summary:     Network: convert network devices to use struct device
> instead of class_device
>=20
> which corresponds to 43cb76d91ee85f579a69d42bc8efc08bac560278 in git.

Yup, sysfs breakage/hal stuff. Can you try with a recent hal? And maybe
try to bisect the iwconfig stop thing if you've got enough time...

johannes

--=-Bdf9yS6/Qs+ddGU6eaEw
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF61is/ETPhpq3jKURAuvvAKC1g4NYvVxDXEyrhIwv4uXtMx4+dwCcD/90
gjfwMbRL2vJ46swsF1N2/1E=
=2Oqf
-----END PGP SIGNATURE-----

--=-Bdf9yS6/Qs+ddGU6eaEw--

From: Bryan Kadzban <bryan@kadzban.is-a-geek.net>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Wed, 19 Aug 2009 21:41:14 -0700
Message-ID: <4A8CD3EA.5080005@kadzban.is-a-geek.net>
References: <5DDAB7BA7BDB58439DD0EED0B8E9A3AE011CD92D@ausx3mpc102.aus.amer.dell.com> <5DDAB7BA7BDB58439DD0EED0B8E9A3AE011CD964@ausx3mpc102.aus.amer.dell.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-ripemd160;
 protocol="application/pgp-signature";
 boundary="------------enig7D84CB79D414C4079BD22054"
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org
To: Jordan_Hargrave@Dell.com
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <5DDAB7BA7BDB58439DD0EED0B8E9A3AE011CD964@ausx3mpc102.aus.amer.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig7D84CB79D414C4079BD22054
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Jordan_Hargrave@Dell.com wrote:
> example udev config:
> SUBSYSTEM=3D=3D"net", SYMLINK+=3D"net/by-mac/$sysfs{ifindex}.$sysfs{add=
ress}"

So say I have two NICs, currently named eth0/eth1, and I keep them using
those names via the current udev MAC address rules.  Furthermore, say
that this patch is applied, and so I start using 0.<addr0> and 1.<addr1>
in my network configuration, instead of eth0/eth1.

Now, say that on some given boot, these two NICs show up to the kernel
in a different order.  I might move them around in the machine (this is,
after all, the point behind using the MAC as the identifier ;-) ), or
one of them might be USB, or something else random changes the order.
With this rule, they're now at 0.<addr1> and 1.<addr0>.

In other words, these names are not actually persistent.

If you get rid of the $sysfs{ifindex}, then this should work.  If that
doesn't work for what you're trying to do for some reason, then you can
make another directory of symlinks by-ifindex, and use that; that should
work as well.  But coupling the ifindex to the MAC address like this
doesn't work.  (In general, coupling any two unrelated attributes when
trying to do persistent names doesn't work.)


--------------enig7D84CB79D414C4079BD22054
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEAREDAAYFAkqM0/MACgkQYasYN+YI5W5f3QCfZYnGlj1iA7zPkhc6SGUxF4TW
+t4An0AzJnI4u1W5kKYvyhemBR3fFfkk
=knXl
-----END PGP SIGNATURE-----

--------------enig7D84CB79D414C4079BD22054--

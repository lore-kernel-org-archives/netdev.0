From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Proper suspend/resume flow
Date: Sat, 29 Mar 2014 20:08:14 +0000
Message-ID: <1396123694.2898.93.camel@deadeye.wl.decadent.org.uk>
References: <20140326115828.GZ7528@n2100.arm.linux.org.uk>
	 <1396111046.2898.88.camel@deadeye.wl.decadent.org.uk>
	 <20140329180347.GW7528@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-jKdAVVJbYQZU4L9uqGzf"
Cc: netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:32948 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751885AbaC2UIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 16:08:21 -0400
In-Reply-To: <20140329180347.GW7528@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-jKdAVVJbYQZU4L9uqGzf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-03-29 at 18:03 +0000, Russell King - ARM Linux wrote:
[...]
> That said, for the case where a network driver does all it's packet
> processing in the NAPI poll function, I think calling napi_disable()
> is a good way to ensure that the poll function is not running, and
> therefore there are can be no netif_wake_queue() calls - or anything
> other than the ndo_start_xmit touching the rings or the device.  This
> is needed anyway to stop receive packet processing looking at its
> ring.
>=20
> So, I've now come to this sequence:
>=20
> suspend()
> {
> 	if (netif_running()) {
> 		napi_disable();
> 		netif_tx_lock();
> 		netif_device_detach();
> 		netif_tx_unlock();
> 	}
> 	... suspend device ...
> }
[...]

This is missing netif_stop_queue(), but I assume you do that somewhere
after netif_device_detach().  I think this should work.

Ben.

--=20
Ben Hutchings
[W]e found...that it wasn't as easy to get programs right as we had thought=
.
... I realized that a large part of my life from then on was going to be sp=
ent
in finding mistakes in my own programs. - Maurice Wilkes, 1949

--=-jKdAVVJbYQZU4L9uqGzf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUzcoLue/yOyVhhEJAQobbw/9G81NB/PppNw6fD2cHWtKZI7WhcI4KB3K
AfoGxUaKmZX87+4oqkAoJx+zi73oQCf3yx9dXdflc80GddBDVhrnfVXeT95x7oy0
d+yHrsH49UpISVVfEYPygiUW/HPwo1XKE7/xFlq5QPxzpJBZaLCoWP1mRrknm5S0
pvRhHL/lbjHaEaygAI3N6OzIA22ATsbPhdmYGtyWAJmwrnzf2AgxEYRTcRhQlVXg
T9d+7sIXo0JKp7FRLc1bBjntuchMMDF/ranxjpWIuOvH/72LAKmgIVgz1PRX3Sdo
yL6u8vIopRUvmJfswdLN8T60ZJ7xTkQZAL5Z0Xd7uL/WEPK+GXRtkdFpiF2ekfhu
i1dmfrNixm38a7kMWxeB6GycUyFBUxJCB/eG8pG0UhkfXixqiri5t58a/ZyTNFYR
jG9gllfUj/vw2LXQxMULJkgg1PQrvV7gVrEshvXMC9WAPvDBBsWewuxTFTjwTzxz
OaLPXXaX250YCgQyshPGlnD5WDm1zxY+JdJ4b42G0QOuCxYZpy7eMV+glap7jSTD
t0ODsb2mNdRc9I2ie5EOIjWvjCyrSHuOX85ldI97TB7bzXKZ7sY9jBzdGc2YrOtp
LcOR1sE9waILGAjFCjWN8KrrEbebTG/9Bqm6fk8B03fwSSAoX54lwJsukNvmTj4T
jGyie87LX5E=
=sy+4
-----END PGP SIGNATURE-----

--=-jKdAVVJbYQZU4L9uqGzf--

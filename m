From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 5/7] Driver: Vmxnet3: Add support for
 get_coalesce, set_coalesce ethtool operations
Date: Mon, 09 May 2016 01:17:20 +0100
Message-ID: <1462753040.9308.11.camel@decadent.org.uk>
References: <1462576336-83513-1-git-send-email-skhare@vmware.com>
	  <1462576336-83513-6-git-send-email-skhare@vmware.com>
	 <1462622686.19332.33.camel@decadent.org.uk>
	 <alpine.DEB.2.10.1605081335140.13942@shri-linux.eng.vmware.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-iIIyL2eSdGEq7M+apQGr"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com, Keyong Sun <sunk@vmware.com>,
	Manoj Tammali <tammalim@vmware.com>
To: Shrikrishna Khare <skhare@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1605081335140.13942@shri-linux.eng.vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-iIIyL2eSdGEq7M+apQGr
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2016-05-08 at 13:55 -0700, Shrikrishna Khare wrote:
>=20
> On Sat, 7 May 2016, Ben Hutchings wrote:
>=20
> > On Fri, 2016-05-06 at 16:12 -0700, Shrikrishna Khare wrote:
> > [...]
> > > +static int
> > > +vmxnet3_set_coalesce(struct net_device *netdev, struct ethtool_coale=
sce *ec)
> > > +{
> > [...]
> > > +=C2=A0=C2=A0=C2=A0switch (ec->rx_coalesce_usecs) {
> > > +=C2=A0=C2=A0=C2=A0case VMXNET3_COALESCE_DEFAULT:
> > > +=C2=A0=C2=A0=C2=A0case VMXNET3_COALESCE_DISABLED:
> > > +=C2=A0=C2=A0=C2=A0case VMXNET3_COALESCE_ADAPT:
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if=
 (ec->tx_max_coalesced_frames ||
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0ec->tx_max_coalesced_frames_irq ||
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0ec->rx_max_coalesced_frames_irq) {
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0return -EINVAL;
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0}
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0me=
mset(adapter->coal_conf, 0, sizeof(*adapter->coal_conf));
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0ad=
apter->coal_conf->coalMode =3D ec->rx_coalesce_usecs;
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0br=
eak;
> > > +=C2=A0=C2=A0=C2=A0case VMXNET3_COALESCE_STATIC:
> > [...]
> >=C2=A0
> > I don't want to see drivers introducing magic values for fields that
> > are denominated in microseconds (especially not for 0, which is the
> > correct way to specify 'no coalescing'). =C2=A0If the current
> > ethtool_coalesce structure is inadequate, propose an extension.
>=20
> For vmxnet3, we need an ethtool mechanism to indicate coalescing mode to=
=C2=A0
> the device.
>=20
> Would a patch that maps 0 to 'no coalescing' be acceptable? That is:
>=20
> rx-usecs =3D 0 -> coalescing disabled.
> rx-usecs =3D 1 -> default (chosen by the device).
> rx-usecs =3D 2 -> adaptive coalescing.
> rx-usecs =3D 3 -> static coalescing.

I still don't like it much. =C2=A0For the 3 special values (0 isn't really
special):

1 =3D default: When the driver sets the virtual device to this mode, can it=
 then read back what the actual settings are, or are they hidden? =C2=A0If =
it can, then userland can also read the defaults and explicitly return to t=
hem later. =C2=A0But I do see the usefulness of an explicit request to rese=
t to defaults.

2 =3D adaptive coalescing: There are already fields to request adaptive coa=
lescing; you should support them.

3 =3D static coalescing: I don't understand what this means.

> all other rx-usecs values -> rate based coalescing where rx-usecs denotes=
=C2=A0
> rate.
>=20
> Alternatively: I don't think new members could be added to struct=C2=A0
> ethtool_coalesce without breaking compatibility.

That's right, unfortunately.

> Thus, I could extend=C2=A0coalescing as follows:
> - new struct ethtool_coalesce_v2 with coalesce_mode (along with all the=
=C2=A0
> members of struct ethtool_coalesce).
> - introduce new ETHTOOL_{G,S}COALESCE_V2 commands.
> - extend userspace ethtool to invoke new commands.
>=20
> Could you please advice?

That's roughly how you would extend it. =C2=A0Though we would probably want
to consider making other extensions to interrupt coalescing control at
the same time.

Ben.

> =20
Ben Hutchings
If you seem to know what you are doing, you'll be given more to do.
--=-iIIyL2eSdGEq7M+apQGr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXL9cQAAoJEOe/yOyVhhEJutUP/2V79oxzm80af1sl3OopgGvC
+woVBBmQRLs5dZld+pCvVQuY8sr7uLUopr2GtftaCjRw0PnIObEjPhrbKmGX9Nig
3WojV55gFTgJsi2vojiUsuxZPDIrE2rsRG/wU87Nojod0r6NwioWt85p/SyRwQTq
yheUX9sMQAQ3PeE4CmBDK6YsUL5yUhXUyporANvKVfxYYbqjBxjBboioz9gfEByM
5VTo4RRQzqXyK935+aGFUE/BRYTUTyYm1mlssDzj2DUd8ttzpMkdNl8WCPckxpkB
fJNixEaHKc4rK8IrNJWL2favwWpt+WEDA6BbYPBQRSh9VxnMmspW4j1klM8pNWxi
BYvOJlhRpzN9Ly2dXb5ZhpHxmUBc6/mX6oqwRh/jaC5QMECU4gfhA3RJjbNwzzEu
WmKF4AGhF7rfxwca9hW5zJlTN7woBn5AXxDcgapdn5hSwn9qPpkgnZ3gvgyZngzM
tNlV/K+ddVHonPG334M5VLxNREqMFC6AlGReAcOSv8UgRJtXUBel8XcEah00Jjc/
KiDCrFcjJnOEfcByU/QNGVrZ4ZoFd9HskUifPYwc17z5l44rU34DYyM/Wz0QhI5X
K8/jjQe6jCpgI0vczy5mgnQoAEKxOl7e2IvfUFKNIf1yo4ZRIfiIfJWjJ+QrmT8g
5i/HibfEEZ70ZqgG0S0L
=IwBj
-----END PGP SIGNATURE-----

--=-iIIyL2eSdGEq7M+apQGr--

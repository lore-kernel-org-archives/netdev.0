From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2 net 1/2] drivers/net: Disable UFO through virtio
Date: Fri, 21 Nov 2014 18:46:52 +0000
Message-ID: <1416595612.7215.21.camel@decadent.org.uk>
References: <1414693592.16849.61.camel@decadent.org.uk>
	<1414693632.16849.62.camel@decadent.org.uk>
	<20141119091455.GA26036@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============9076932529439333856=="
Cc: netdev@vger.kernel.org, Hannes Frederic Sowa <hannes@stressinduktion.org>,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20141119091455.GA26036@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--===============9076932529439333856==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Y3PArxriUEgvo6qgAkWM"


--=-Y3PArxriUEgvo6qgAkWM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-11-19 at 11:14 +0200, Michael S. Tsirkin wrote:
> On Thu, Oct 30, 2014 at 06:27:12PM +0000, Ben Hutchings wrote:
> > IPv6 does not allow fragmentation by routers, so there is no
> > fragmentation ID in the fixed header.  UFO for IPv6 requires the ID to
> > be passed separately, but there is no provision for this in the virtio
> > net protocol.
> >=20
> > Until recently our software implementation of UFO/IPv6 generated a new
> > ID, but this was a bug.  Now we will use ID=3D0 for any UFO/IPv6 packet
> > passed through a tap, which is even worse.
> >=20
> > Unfortunately there is no distinction between UFO/IPv4 and v6
> > features, so disable UFO on taps and virtio_net completely until we
> > have a proper solution.
> >=20
> > We cannot depend on VM managers respecting the tap feature flags, so
> > keep accepting UFO packets but log a warning the first time we do
> > this.
> >=20
> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> > Fixes: 916e4cf46d02 ("ipv6: reuse ip6_frag_id from ip6_ufo_append_data"=
)
>=20
>=20
> There's something I don't understand here. I see:
>=20
>         NETIF_F_UFO_BIT,                /* ... UDPv4 fragmentation */
>=20
> this comment is wrong then?

Yes.

> The patches drastically regress performance for UDPv4 for VMs only, but
> isn't it likely many other devices based their code on this comment?

There's only one hardware driver that implements UFO (s2io), and it does
handle IPv6.

> How about we disable UFO for IPv6 globally, and put the
> flag back in?
> We can then gradually add NETIF_F_UFO6_BIT for devices that
> actually support UFO for IPv6.

Since the corresponding virtio feature bit is understood to include
UFO/IPv6, and existing VMs rely on that, I don't see what this solves.

Ben.

--=20
Ben Hutchings
Beware of bugs in the above code;
I have only proved it correct, not tried it. - Donald Knuth

--=-Y3PArxriUEgvo6qgAkWM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVG+Ioee/yOyVhhEJAQoyUQ/+MycCL5sOJoImHcGnZld0vuHjQ7Xd5Wn+
pPDdYusSLeDu22ysFtX5XE2QZtxb+HcFBqL9Gz+hZY8T0cTfxkNE3oAYwVg7IQ4w
+vZ/7stAb5sJmS8OogPqB5cPcJ9hVyN55vsV5G+kFcPYe9DOdIBd3pMNdXlXl433
PMDzq26P4J9TUjDwkUIRQkKiM3QEQ8v6oNI2SQqye+Sx8hftIgDUcR8m7Ckb6pmj
IeY23kYTNw1Bm7nu45ldQN4rfPUnsUltvrFzSAv93CBKegMOFit+Clz5X56m66Jg
Tu3lV3EjSaAvUZWYlJBnkZ1bEOUT7Vli7OODGsJHPaMQEcaxBJLhaSJSBWxGx086
oEUaQxISkpTXD2aT1XhYuy2Odh4ZbxrWosU/JU2d57qW/f8BHfhEr2juVV7jZwTB
kOKdVL8CLfW3nCnY9pxuKtNv3RCNexYkVN6xVpuWvkxVwVuuGOrpo/BP8KznlEqD
/Lb1Kb5cc4YWKhfPNgVzKHxj7tcMiuiViToVLQs3/jOeGi8tbpLI6i9cTpUEM1QY
rhX0X4kG+deZ3IdCXTTo/frNMpE9OzOQ5bR3GTN6qKspVn3AOxNh/Z5Jr3ZcTt6e
mr4x+wrAQ6Y1Jb6E9t5bV7vw+a9NX3MFwIvgS1hyBlEjzq/hgcu+cH2HQHT3iUnb
EPnROsImL7o=
=sNxZ
-----END PGP SIGNATURE-----

--=-Y3PArxriUEgvo6qgAkWM--

--===============9076932529439333856==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============9076932529439333856==--

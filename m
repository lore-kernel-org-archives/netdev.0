From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH v2 0/5] Add virtio transport for AF_VSOCK
Date: Wed, 9 Dec 2015 10:38:04 +0800
Message-ID: <20151209023804.GC22280@stefanha-x1.localdomain>
References: <1449038643-25971-1-git-send-email-stefanha@redhat.com>
 <20151204074504.GA21363@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bKyqfOwhbdpXa4YI"
Cc: kvm@vger.kernel.org, Matt Benjamin <mbenjamin@redhat.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	netdev@vger.kernel.org, matt.ma@linaro.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151204074504.GA21363@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--bKyqfOwhbdpXa4YI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Dec 04, 2015 at 09:45:04AM +0200, Michael S. Tsirkin wrote:
> On Wed, Dec 02, 2015 at 02:43:58PM +0800, Stefan Hajnoczi wrote:
> > 1. The 3-way handshake isn't necessary over a reliable transport (virtq=
ueue).
> >    Spoofing packets is also impossible so the security aspects of the 3=
-way
> >    handshake (including syn cookie) add nothing.  The next version will=
 have a
> >    single operation to establish a connection.
>=20
> It's hard to discuss without seeing the details, but we do need to
> slow down guests that are flooding host with socket creation requests.
> The handshake is a simple way for hypervisor to defer
> such requests until it has resources without
> breaking things.

I'll send an updated virtio-vsock device specification so we can discuss
it.

VMCI simply uses sk->sk_max_ack_backlog in
net/vmw_vsock/vmci_transport.c.  If backlog (from listen(2)) is maxed
out then the connection is refused.

The same would work for virtio-vsock and there is no advantage to the
3-way handshake.

> > 2. Credit-based flow control doesn't work for SOCK_DGRAM since multiple=
 clients
> >    can transmit to the same listen socket.  There is no way for the cli=
ents to
> >    coordinate buffer space with each other fairly.  The next version wi=
ll drop
> >    credit-based flow control for SOCK_DGRAM and only rely on best-effort
> >    delivery.  SOCK_STREAM still has guaranteed delivery.
>=20
> I suspect in the end we will need a measure of fairness even
> if you drop packets. And recovering from packet loss is
> hard enough that not many applications do it correctly.
> I suggest disabling SOCK_DGRAM for now.

I'm not aware of a SOCK_DGRAM user at this time.  Will disable it for
now.

--bKyqfOwhbdpXa4YI
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJWZ5QMAAoJEJykq7OBq3PId9UH/3AtdTnom65Ri5q+blEVDMoZ
tEkQXlDoxfM0mQ3l8qwtO3j65JFTEQFXTNYCH2MSHd3UPYFkAOSgJbUNWTDjJ06O
9K3Y93YSOFRI3245GE49gxiaw+mXBpHuVjrvIApOMh+PHzkmDRXVNpndV/tdlqSZ
2lQwiB9uMTHUfZUY3qXpdcI6X/UTJJzQsBr/JJdTqriWY+X1It+V4sE4FsQo+QHJ
p41lzOS+WrKxEIwqyDpyJcqfj0eEYbTzjs1ldDLDEeWr48c6OWoCMEmt3S86ePhO
rgTtxfBEv9NZ/wKCHU3GLDRwxJfsB+rd01fHuqZO4o7N83vnna6Gl0OgJI/BGJY=
=VEuq
-----END PGP SIGNATURE-----

--bKyqfOwhbdpXa4YI--

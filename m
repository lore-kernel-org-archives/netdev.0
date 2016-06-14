From: Henrik Austad <henrik@austad.us>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Tue, 14 Jun 2016 10:35:55 +0200
Message-ID: <20160614083555.GA21689@sisyphus.home.austad.us>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <20160613114713.GA9544@localhost.localdomain>
 <575ED7BC.4000803@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LQksG6bCIzRHxTLp"
Cc: Richard Cochran <richardcochran@gmail.com>,
	linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
	alsa-devel@vger.kernel.org, netdev@vger.kernel.org,
	henrik@austad.us, Arnd Bergmann <arnd@linaro.org>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <575ED7BC.4000803@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 13, 2016 at 08:56:44AM -0700, John Fastabend wrote:
> On 16-06-13 04:47 AM, Richard Cochran wrote:
> > [...]
> > Here is what is missing to support audio TSN:
> >=20
> > * User Space
> >=20
> > 1. A proper userland stack for AVDECC, MAAP, FQTSS, and so on.  The
> >    OpenAVB project does not offer much beyond simple examples.
> >=20
> > 2. A user space audio application that puts it all together, making
> >    use of the services in #1, the linuxptp gPTP service, the ALSA
> >    services, and the network connections.  This program will have all
> >    the knowledge about packet formats, AV encodings, and the local HW
> >    capabilities.  This program cannot yet be written, as we still need
> >    some kernel work in the audio and networking subsystems.
> >=20
> > * Kernel Space
> >=20
> > 1. Providing frames with a future transmit time.  For normal sockets,
> >    this can be in the CMESG data.  For mmap'ed buffers, we will need a
> >    new format.  (I think Arnd is working on a new layout.)
> >=20
> > 2. Time based qdisc for transmitted frames.  For MACs that support
> >    this (like the i210), we only have to place the frame into the
> >    correct queue.  For normal HW, we want to be able to reserve a time
> >    window in which non-TSN frames are blocked.  This is some work, but
> >    in the end it should be a generic solution that not only works
> >    "perfectly" with TSN HW but also provides best effort service using
> >    any NIC.
> >=20
>=20
> When I looked at this awhile ago I convinced myself that it could fit
> fairly well into the DCB stack (DCB is also part of 802.1Q). A lot of
> the traffic class to queue mappings and priories could be handled here.
> It might be worth taking a look at ./net/sched/mqprio.c and ./net/dcb/.

Interesting, I'll have a look at dcb and mqprio, I'm not familiar with=20
those systems. Thanks for pointing those out!

I hope that the complexity doesn't run crazy though, TSN is not aimed at=20
datacentra, a lot of the endpoints are going to be embedded devices,=20
introducing a massive stack for handling every eventuality in 802.1q is=20
going to be counter productive.

> Unfortunately I didn't get too far along but we probably don't want
> another mechanism to map hw queues/tcs/etc if the existing interfaces
> work or can be extended to support this.

Sure, I get that, as long as the complexity for setting up a link doesn't=
=20
go through the roof :)

Thanks!

--=20
Henrik Austad

--LQksG6bCIzRHxTLp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAldfwesACgkQ6k5VT6v45lm4UgCgx5tJr0oxqxBs3gOFge4/WGxn
2OYAoPFryz9agirAG2n5bXTRHKBQbDo3
=Nu4n
-----END PGP SIGNATURE-----

--LQksG6bCIzRHxTLp--

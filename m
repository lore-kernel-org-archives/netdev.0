From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Tue, 10 May 2016 16:50:56 -0400
Message-ID: <1462913455.16365.12.camel@redhat.com>
References: <1462896230.6687.74.camel@redhat.com>
	 <1462896539.23934.93.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1462911770.5333.11.camel@redhat.com>
	 <20160510.164538.1375529074383780155.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256"; protocol="application/pgp-signature"; boundary="=-HpAE9kBurz3ExaIP5NKA"
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	edumazet@google.com, jiri@mellanox.com, daniel@iogearbox.net,
	ast@plumgrid.com, aduyck@mirantis.com, tom@herbertland.com,
	peterz@infradead.org, mingo@kernel.org, hannes@stressinduktion.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, pabeni@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160510.164538.1375529074383780155.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-HpAE9kBurz3ExaIP5NKA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-05-10 at 16:45 -0400, David Miller wrote:
> From: Paolo Abeni <pabeni@redhat.com>
> Date: Tue, 10 May 2016 22:22:50 +0200
>=20
> > On Tue, 2016-05-10 at 09:08 -0700, Eric Dumazet wrote:
> >> On Tue, 2016-05-10 at 18:03 +0200, Paolo Abeni wrote:
> >>=C2=A0
> >> > If a single core host is under network flood, i.e. ksoftirqd is
> >> > scheduled and it eventually (after processing ~640 packets) will
> let the
> >> > user space process run. The latter will execute a syscall to
> receive a
> >> > packet, which will have to disable/enable bh at least once and
> that will
> >> > cause the processing of another ~640 packets. To receive a
> single packet
> >> > in user space, the kernel has to process more than one thousand
> packets.
> >>=C2=A0
> >> Looks you found the bug then. Have you tried to fix it ?
> =C2=A0...
> > The ksoftirq and the local_bh_enable() design are the root of the
> > problem, they need to be touched/affected to solve it.
>=20
> That's not what I read from your description, processing 640 packets
> before going to ksoftirqd seems to the be the absolute root problem.

What would a fix for that look like?

Keep track of the number of processed incoming packets,
and the number of packets handed off, and defer to
ksoftirqd earlier if the statistics suggest packets are
getting dropped on the floor?

Is there a cheap way to do that kind of thing?

--=20
All Rights Reversed.


--=-HpAE9kBurz3ExaIP5NKA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXMkmvAAoJEM553pKExN6DzAgIALEIisdS4vyXrvgkxLg2A/k6
1tj3rATMINT7HhwUnenC/CgYuG64950/Gb9nT5icZR7HjAElBrkSVLWNLG4l7ZjF
dIOrG8t55susDKE3g01fMuWhXM7dpU1AtGsKkHFLGIebiZ9zo5k6YRM7JAk/tySj
pVeQT1lLLzPY8sudgjuqq6cz/mewbxzP4tyB+jHdckyBCV7Qbix061tTGEqVfHQo
uOLCIW0RHBW7GFUN79RxZ4scNyICl1yqr53chdgICjkH9Ohlod06/6z0tdvq98fx
2Jplw0d8tdiSGCB2FjuYOGoBhK78jF/i79rf3C0bDcUdkEC9XKto55GjQqczrlU=
=9y3K
-----END PGP SIGNATURE-----

--=-HpAE9kBurz3ExaIP5NKA--

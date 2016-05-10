From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Tue, 10 May 2016 17:01:21 -0400
Message-ID: <1462914081.16365.13.camel@redhat.com>
References: <1462911770.5333.11.camel@redhat.com>
	 <20160510.164538.1375529074383780155.davem@davemloft.net>
	 <1462913455.16365.12.camel@redhat.com>
	 <20160510.165215.1602157973141296642.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-LCu/Zak3y6B0O+IipVf/"
Cc: pabeni@redhat.com, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	edumazet@google.com, jiri@mellanox.com, daniel@iogearbox.net,
	ast@plumgrid.com, aduyck@mirantis.com, tom@herbertland.com,
	peterz@infradead.org, mingo@kernel.org, hannes@stressinduktion.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160510.165215.1602157973141296642.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-LCu/Zak3y6B0O+IipVf/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-05-10 at 16:52 -0400, David Miller wrote:
> From: Rik van Riel <riel@redhat.com>
> Date: Tue, 10 May 2016 16:50:56 -0400
>=20
> > On Tue, 2016-05-10 at 16:45 -0400, David Miller wrote:
> >> From: Paolo Abeni <pabeni@redhat.com>
> >> Date: Tue, 10 May 2016 22:22:50 +0200
> >>=C2=A0
> >> > On Tue, 2016-05-10 at 09:08 -0700, Eric Dumazet wrote:
> >> >> On Tue, 2016-05-10 at 18:03 +0200, Paolo Abeni wrote:
> >> >>=C2=A0
> >> >> > If a single core host is under network flood, i.e. ksoftirqd
> is
> >> >> > scheduled and it eventually (after processing ~640 packets)
> will
> >> let the
> >> >> > user space process run. The latter will execute a syscall to
> >> receive a
> >> >> > packet, which will have to disable/enable bh at least once
> and
> >> that will
> >> >> > cause the processing of another ~640 packets. To receive a
> >> single packet
> >> >> > in user space, the kernel has to process more than one
> thousand
> >> packets.
> >> >>=C2=A0
> >> >> Looks you found the bug then. Have you tried to fix it ?
> >> =C2=A0...
> >> > The ksoftirq and the local_bh_enable() design are the root of
> the
> >> > problem, they need to be touched/affected to solve it.
> >>=C2=A0
> >> That's not what I read from your description, processing 640
> packets
> >> before going to ksoftirqd seems to the be the absolute root
> problem.
> >=C2=A0
> > What would a fix for that look like?
> >=C2=A0
> > Keep track of the number of processed incoming packets,
> > and the number of packets handed off, and defer to
> > ksoftirqd earlier if the statistics suggest packets are
> > getting dropped on the floor?
>=20
> Not by packet count but by something more easily to measure and
> scalable to fairness like processing time.

I need to get back to fixing irq & softirq time accounting,
which does not currently work correctly in all time keeping
modes...

--=20
All Rights Reversed.


--=-LCu/Zak3y6B0O+IipVf/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXMkwhAAoJEM553pKExN6DlPYH/izXWpR8RmZUGCtbRAOAw3lx
J/St/WfTcO8MhFccL11dArng7UR8yANj0biQpv7hGp9G9MVpCn8/TY751m0hMbAc
SEh/Y2wXKE965ZxhHk1ta8jvDAFiPg0xPOejouQJdBE9a0oKdaPPKyIYb0nIjfuv
zNnj63kBDjWcNKHKp53so53XBGBJpMPtYdy29KqrWjKQvqoKZhX5jaZ8eYsQ3lZ+
jLOaxczigDYL0KyOa5yt2+nX+hxTHWCaen4SX0gv1Yx4Le3wnTUu4NcWk52mVijZ
qylSTfsPfhcMW7PZm/oHIbD5zOFkSjmNXIAgyQln/VbErh66hL8CN45Gu/SVDY4=
=EXjE
-----END PGP SIGNATURE-----

--=-LCu/Zak3y6B0O+IipVf/--

From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RFC 0/2] pm,net: Introduce QoS requests per CPU
Date: Tue, 25 Mar 2014 22:47:29 +0000
Message-ID: <1395787649.28354.40.camel@deadeye.wl.decadent.org.uk>
References: <1395753505-13180-1-git-send-email-amirv@mellanox.com>
	 <1395760447.12610.132.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-fqzYp+uS3laeJR2nj5qf"
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, linux-pm@vger.kernel.org,
	netdev@vger.kernel.org, Pavel Machek <pavel@ucw.cz>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Len Brown <len.brown@intel.com>, yuvali@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>, idos@mellanox.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <1395760447.12610.132.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-fqzYp+uS3laeJR2nj5qf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-03-25 at 08:14 -0700, Eric Dumazet wrote:
> On Tue, 2014-03-25 at 15:18 +0200, Amir Vadai wrote:
>=20
> > The current pm_qos implementation has a problem. During a short pause i=
n a high
> > bandwidth traffic, the kernel can lower the c-state to preserve energy.
> > When the pause ends, and the traffic resumes, the NIC hardware buffers =
may be
> > overflowed before the CPU starts to process the traffic due to the CPU =
wake-up
> > latency.
>=20
> This is the point I never understood with mlx4
>=20
> RX ring buffers should allow NIC to buffer quite a large amount of
> incoming frames. But apparently we miss frames, even in a single TCP
> flow. I really cant understand why, as sender in my case do not have
> more than 90 packets in flight (cwnd is limited to 90)
[...]

The time taken for software to clean the RX ring is only half the story.

A DMA write requires every CPU's cache controller to invalidate affected
cache lines.  It may also require reading from cache, if the write
covers only part of a cache line.  So at least the cache controllers
need to be woken from sleep, and until then all DMA writes must be
buffered in some combination of CPUs, bridges and the network
controller's RX FIFOs.  If those buffers aren't long enough for the
delay, packets will be dropped.  (Ethernet flow control may help with
this, if enabled.)

Back in 2007, colleagues at Solarflare measured DMA write delays of
about 10 us when CPUs had to be woken up, rising to 40-50 us for one
buggy Intel model.  This motivated a large increase to RX FIFO size in
the SFC4000B and subsequent controllers.

Ben.

--=20
Ben Hutchings
Make three consecutive correct guesses and you will be considered an expert=
.

--=-fqzYp+uS3laeJR2nj5qf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUzIHgee/yOyVhhEJAQrNuhAAg6Fx4SyD0AuaK60OvnxvfycpFxORN+Qv
QM4MBMD2AFKmYiTtx+GVWvxYHH6lEb2SwLYfyrpcgTmIEEubj2uv0p9wq6Dw7wJf
HNeLYV8pdo/HXwf5jqoEGaGsMXaEaf7jfp74lE1vpp5+BtDeZxXn2e4lvxvNkDga
xrqMzOtdeH5NpaN7w8hIynsHlmNNomy5rCNf8qGXJqa8fc5064exTIpQbow4jdZR
bS2F8nzSrtz+9GlTPVyIPvSh+Oqp13qnCdTxUs9GD4GZOAzEs3dHR3rv2jcRS6+O
9a8qxa5Q7YQeGflbiB2mfl0OLgFZ4N1lrYrUytyy/6Rch7h+s/5gom4NQIldaE6S
/g5Kfx6KUkO1IAKayaO4BlJ1bwmXG+D18coljXQNBXTZ8lMoYuVJmx4CyK1VBIdy
wF+SUXT6VOiVS8fyRu7OF1zPsSgf/3Ts5nb9Xj9x2zK027/E1Tci/cKQABl4OzA1
norwcd/IyMarj1TgZx+jjlx8zhfAUlKkPtNsevPMAdTZcfopzsKiI/6q8Hr4rvgG
kjmbO4nbuB5yY62Lm5B/HpmTD6AwL6WLfH+O3Nt8JxSEXnAYPzhE68bvWARs2AAn
OLrSWiUDdlex8D/pjPPPvdXcoMsv9QLYDeXNeh5FgYsDViNQesJ5/j3eWCV7O8r2
kqJ+K6GWq6k=
=WSGf
-----END PGP SIGNATURE-----

--=-fqzYp+uS3laeJR2nj5qf--

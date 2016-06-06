From: Clark Williams <williams@redhat.com>
Subject: Re: [PATCH][RT] netpoll: Always take poll_lock when doing polling
Date: Mon, 6 Jun 2016 07:03:22 -0500
Message-ID: <20160606070322.39ac701e@sluggy.hsv.redhat.com>
References: <20160526195641.6c26e979@gandalf.local.home>
	<20160602161235.GA12971@linutronix.de>
	<20160604071131.08d449db@grimm.local.home>
	<CAOuSAjfXsLQWkrcE7Y3t-k0Bv5qieqgziu8Zf-au4SK-rLvRHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 boundary="Sig_/DebhqehmN74Y/gkGkV78YZ3"; protocol="application/pgp-signature"
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-rt-users <linux-rt-users@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Alison Chaiken <alison@peloton-tech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOuSAjfXsLQWkrcE7Y3t-k0Bv5qieqgziu8Zf-au4SK-rLvRHQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/DebhqehmN74Y/gkGkV78YZ3
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 5 Jun 2016 08:16:58 -0700
Alison Chaiken <alison@peloton-tech.com> wrote:

> Steven Rostedt suggests in reference to "[PATCH][RT] netpoll: Always
> take poll_lock when doing polling"
> >> [ Alison, can you try this patch ] =20
>=20
> Sebastian follows up:
> >Alison, did you try it? =20
>=20
> Sorry for not responding sooner.   I was hoping to come to a complete
> understanding of the system before replying . . .
>=20
> I did try that patch, but it hasn't made much difference.   Let me
> back up and restate the problem I'm trying to solve, which is that a
> DRA7X OMAP5 SOC system running a patched 4.1.18-ti-rt kernel has a
> main event loop in user space that misses latency deadlines under the
> test condition where I ping-flood it from another box.   While in
> production, the system would not be expected to support high rates of
> network traffic, but the instability with the ping-flood makes me
> wonder if there aren't underlying configuration problems.

What sort of tunings have you applied, regarding thread and interrupt affin=
ity? If you have not, you might try isolating one of your cores and just ru=
n the user-space application on that core, with interrupt threads running o=
n the other core. You could use the 'tuna' application like this:

	$ sudo tuna --cpus=3D1 --isolate

This will move all the threads that *can* be moved off of cpu1 (probably to=
 cpu0 since I believe the OMAP5 is a dual-core processor?).=20

Also, what scheduler policy/priority are you using for the user-space appli=
cation?

Clark

--Sig_/DebhqehmN74Y/gkGkV78YZ3
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCgAGBQJXVWaLAAoJEOI5asVwYXLr/1MQALiCdQpIYgm+0Fr5PoYRd45j
kmCEBuOgLgAEhJzd3uTrTTj9QsOi1DHOGXzW6ldTpT0bvhQd5JyW2N/mePkUH692
t66ZLJ6gD2bt6vAAtLqc3mD8cPtfZdOlbbwspxOqxKbLap6neCIWxiWYvpTqHnma
4Dxyu+Ni5tgZ2jNZcmicyHG7k+0FD6wLmFU0sNc3yXFF/f3SomCJOxL9ctXxKcx+
qDZVs/9bR1WSfMkOQeB3YwUkgjrs4fAEWDUCWs8AZerVWxI4zdeaor5HyYu3SepL
DGQj1sjqrFQRTXQs+CAZuXx8L4GyTja322aESoinn6TAdFJfLzX1YYB6GdYMMcFf
+zOerQjvFH1JoUHWvyKx/APTUL4MOEUZc2pKrDacS1czwlFxL4GRP/iclHmvkHiY
Z3BjrUgkD6pccICFrkfqryJ7pyFDERoxZoqXkELGB2U8DwQ0OTJmoQYTDvcukQMN
2MJzoeqJVVItcNEItgf41TXa6+WnO2F8mhs4TNvvT9tWz/QAKDEsXwjqwra1hFEN
MnYfFPBv5Yi/kJcoE6nLAmjm8NjXOcPrwiR8BmEdrjPTO71Ujsp1HcrBv1dXtJcF
zHHpb/h6xSsF4Njg4gz9bmkqLMt50nFd4vy2i7588Z91jMUfv/iNVhsvgsmqM0KK
+iPrphrDW0Tlpg1EJvHN
=OUFB
-----END PGP SIGNATURE-----

--Sig_/DebhqehmN74Y/gkGkV78YZ3--

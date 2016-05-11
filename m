From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Wed, 11 May 2016 11:01:43 -0400
Message-ID: <1462978903.7134.33.camel@redhat.com>
References: <cover.1462886866.git.pabeni@redhat.com>
	 <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
	 <90f3db8c-c30c-b204-576a-454939ac93ce@stressinduktion.org>
	 <CANn89i+YKrVOgfFwW-2psfCzq5_YLdmbV06-H-1FCOwXdMBuzQ@mail.gmail.com>
	 <94f323a9-515e-4d75-cac8-ef0214f0499e@stressinduktion.org>
	 <1462920697.23934.113.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160511065527.GD3193@twins.programming.kicks-ass.net>
	 <de6ef948-65a4-e7e0-718e-6d37474f65d4@stressinduktion.org>
	 <CANn89i+Op8UsvrsZKKzHfC5j6gLMmY1ZbCg=OY8o4oW8RT5sxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-K1dzotOHwZKWWrZDA9mi"
Cc: Peter Zijlstra <peterz@infradead.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Paolo Abeni <pabeni@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Ingo Molnar <mingo@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53935 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751561AbcEKPBw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2016 11:01:52 -0400
In-Reply-To: <CANn89i+Op8UsvrsZKKzHfC5j6gLMmY1ZbCg=OY8o4oW8RT5sxg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-K1dzotOHwZKWWrZDA9mi
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-05-11 at 07:40 -0700, Eric Dumazet wrote:
> On Wed, May 11, 2016 at 6:13 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>=20
> > This looks racy to me as the ksoftirqd could be in the progress to
> > stop
> > and we would miss another softirq invocation.
>=20
> Looking at smpboot_thread_fn(), it looks fine :
>=20

Additionally, we are talking about waking up
ksoftirqd on the same CPU.

That means the wakeup code could interrupt
ksoftirqd almost going to sleep, but the
two code paths could not run simultaneously.

That does narrow the scope considerably.

--=20
All rights reversed

--=-K1dzotOHwZKWWrZDA9mi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAABAgAGBQJXM0lYAAoJEM553pKExN6DPN4H/2gAdBT/mc1BHccTWPl4a3JK
FIKxo1oJz356WcQZnFEJeDTZlPxbe7RxT/tzQzzbpLi8yDTfTea+9cLwWSIa1g+Y
pEaUhCzpPCiGZnNRnKUwp3Mr5qt9WclXWBO5JglKE65L6v6piBd8uesZOP6SGYIf
EOGg1Aswriu1HQmtkGV3q0ZskHnJVnmf8w2M8S5BqBDOQi+B3oHxALCCECHBMT8V
9Ne/9dG24CobbmNnsJeDhLyst0LEWroIo6PqokoQOuQ+/Rr/rj+MckbEAcgjKYn6
z0rOgtfjcQEV6aGsoGZweFSeYeyzNkBnCV59C6YPWNQRHQL6ie0/4C2t7MdNeLk=
=dNXz
-----END PGP SIGNATURE-----

--=-K1dzotOHwZKWWrZDA9mi--

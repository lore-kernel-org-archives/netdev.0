From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 1/9] net/mlx4_core: Enforce irq affinity
 changes immediatly
Date: Mon, 26 May 2014 18:20:50 +0100
Message-ID: <1401124850.17377.124.camel@deadeye.wl.decadent.org.uk>
References: <1399880605-28772-1-git-send-email-amirv@mellanox.com>
		 <1399880605-28772-2-git-send-email-amirv@mellanox.com>
	 <1400358787.2647.65.camel@deadeye.wl.decadent.org.uk>
	 <5379EC0C.5070004@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-+csJ+ONGw/AflJQk3AFt"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yuval Atias <yuvala@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54255 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751388AbaEZRVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 13:21:33 -0400
In-Reply-To: <5379EC0C.5070004@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+csJ+ONGw/AflJQk3AFt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-05-19 at 14:33 +0300, Amir Vadai wrote:
> On 5/17/2014 11:33 PM, Ben Hutchings wrote:
> > On Mon, 2014-05-12 at 10:43 +0300, Amir Vadai wrote:
> >> From: Yuval Atias <yuvala@mellanox.com>
> >>
> >> During heavy traffic, napi is constatntly polling the complition queue
> >> and no interrupt is fired. Because of that, changes to irq affinity ar=
e
> >> ignored until traffic is stopped and resumed.
> >>
> >> By registering to the irq notifier mechanism, and forcing interrupt wh=
en
> >> affinity is changed, irq affinity changes will be immediatly enforced.
> > [...]
> >
> > This somewhat breaks ARFS in your driver, as that depends on IRQ
> > affinity notification.
> Interesting...
> I missed the fact that irq_set_affinity_notifier is 'set' and not 'add'.
> So, do you have objection if I change the API to have a list of=20
> notifiers instead of only one?

I don't mind.

> > It is also not safe to put an IRQ affinity notification function in a
> > module currently, as the work item for notification doesn't carry a
> > module reference and could be called after the module is removed.
> I can get a module reference when a notifier is added and put it when=20
> the notifier is removed.

Maybe you can drop the reference in the affinity notifier release()
function, though that might still leave a race condition.  But the
module won't be removable until its devices are first removed or at
least brought down (depending on where you add/remove the notifier).

Anyway, I think that the issue you have found is quite general and
should be fixed in the networking core rather than your specific driver.

Ben.

--=20
Ben Hutchings
Humans are not rational beings; they are rationalising beings.

--=-+csJ+ONGw/AflJQk3AFt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU4N3/+e/yOyVhhEJAQqB1g/9HdwObvdr7sbTiYuBI4Qd/qU0OaDL78KZ
kl/NnewvxqwYOg5uYj8pEzK4ZvrLHppXl38uL8QcHOH236g1nkq0jcT4EstAOEBX
UvURJinjfJyWdUk1EC+Ix4IwKuZI7A4Q3SdLUoIeN73VnK7yYsA6MhO4HQtF3mOl
Zx08BV3ktpq6Pi65c6BoM6TYCtuO7DlvhDP36PcIRKJRcQX0UViA3RPo31p5tyGE
NuWe6E49EpXIBj2QBY0ZJ12R+5OvNKRpBQSoR8meMD1FbyCzDsn7Bm4r9DlNTlWm
a6oiR1tuB8yAb7mnIUmpJgkBO9pA5DfoZUygzdFCqxLO7Mis5wT9a+WAx4aMOU1A
BqSGS8/9FjX64tDnJaRRLHKEBvJFbB1bL8F/LVQBY6KI8E/t+vat9pgqijsaHOO5
EmWz1CVw65CXHnxLFdSMcBP3XTqIv69kEcH/gVVrnCUJHY0sAP9s9r+Ugg/lfyVd
cxVH1JdJDjxypxoBtEsWANAQWViXsDsuIquqGRsrbpWcqokujPPMt97mXY5Bkt9U
c0TYvtoh+c6doBQit15tB9gkrvDAAM8nBBgSC0IDlT9Ed2baQSaCYOrfN4+TY7/4
SAWHCbGSxuWncXNySc59O4CIQ/e17E0AlHF3GceAxadJNq9DNYJQXYPF1OMRPcB2
4MmB/GPAN+0=
=JLk+
-----END PGP SIGNATURE-----

--=-+csJ+ONGw/AflJQk3AFt--

From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: net: alignment problem in icmp code
Date: Mon, 22 Oct 2007 06:54:43 +0200
Message-ID: <20071022065443.2f3c1b8a@poseidon.drzeus.cx>
References: <20071021113405.37fa0bc5@poseidon.drzeus.cx>
	<20071021.124814.50617600.davem@davemloft.net>
	<20071021232113.52ce1be7@poseidon.drzeus.cx>
	<20071021.160215.115679567.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=PGP-SHA1; boundary="=_hera.drzeus.cx-16687-1193028855-0001-2"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.drzeus.cx ([85.8.24.16]:45745 "EHLO smtp.drzeus.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750908AbXJVEyv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 00:54:51 -0400
In-Reply-To: <20071021.160215.115679567.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_hera.drzeus.cx-16687-1193028855-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 21 Oct 2007 16:02:15 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Pierre Ossman <drzeus@drzeus.cx>
> Date: Sun, 21 Oct 2007 23:21:13 +0200
>=20
> > Not sure that would be valid. memcpy() is defined as having void*
> > arguments, and the compiler cannot just ignore that if it chooses to
> > inline it.
>=20
> Yes it can, there are C language rules about the alignment of types
> that the compiler completely can take advantage of in those kinds of
> situations.
>=20

I'm not debating that. What I'm saying is that calling memcpy() casts your =
pointers to void* with the included semantical changes. It can't just ignor=
e that because it decides to inline the function. It would be the same thin=
g as when gcc decided to ignore the volatile qualifier on a pointer just be=
cause it could optimize away to the real object and discover it wasn't mark=
ed with volatile. Something that was considered a bug and was fixed.

> If you don't believe me, compile something like the following
> with optimizations enabled:

gcc has had bugs in the past.

> You will get a 64-bit load and a 64-bit store emitted by
> the compiler.  Here is what we get on sparc64:
>=20

I assume those ops cause a bus error on unaligned addresses?

>=20
> However, instead of relying upon magic like this, let's just tell the
> compiler explicitly what it going on by using get_unaligned().
>=20

It wouldn't be magic:

memcpy(&icmp_param.data.icmph, skb_transport_header(skb), sizeof(struct icm=
phdr));

I believe platforms without alignment requirements could optimize this bett=
er than the series of assignments. Not that I think this will be a potentia=
l bottle neck, but still.

> Next, there are redundant stores being done here since the code and
> type are explicitly overwritten in various ways.

Indeed.

Rgds
Pierre

--=_hera.drzeus.cx-16687-1193028855-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFHHC0T7b8eESbyJLgRAqWvAJ0dq5/m5qdJNWe4zLpO7sZQM+sZ5ACgsyoo
ne9pq3zgZ/k8MDIReYPZPbc=
=DN5z
-----END PGP SIGNATURE-----

--=_hera.drzeus.cx-16687-1193028855-0001-2--

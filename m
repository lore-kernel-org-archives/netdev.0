From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: net: alignment problem in icmp code
Date: Sun, 21 Oct 2007 11:34:05 +0200
Message-ID: <20071021113405.37fa0bc5@poseidon.drzeus.cx>
References: <20071020233540.43d2f103@poseidon.drzeus.cx>
	<20071020.221257.78359286.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=PGP-SHA1; boundary="=_hera.drzeus.cx-32160-1192959221-0001-2"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.drzeus.cx ([85.8.24.16]:50501 "EHLO smtp.drzeus.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751313AbXJUJeR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Oct 2007 05:34:17 -0400
In-Reply-To: <20071020.221257.78359286.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_hera.drzeus.cx-32160-1192959221-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 20 Oct 2007 22:12:57 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Pierre Ossman <drzeus@drzeus.cx>
> Date: Sat, 20 Oct 2007 23:35:40 +0200
>=20
> > Structure assignment have to be aligned just like any assignment, and t=
he skb could point to anything. So take the safe route and use a memcpy().
> >=20
> > Signed-off-by: Pierre Ossman <drzeus@drzeus.cx>
>=20
> Unfortunately this doesn't work, GCC can inline the memcpy just like
> the assignment.
>=20
> I tried to use a similar trick in the net/xfrm/xfrm_user.c code
> but in the end it doesn't work at all.

Inlining isn't the problem, but the defined semantics of assignment versus =
memcpy(). memcpy() must work on any region of memory, whilst assignment mus=
t only work on a properly aligned object. Since icmphdr contains a u32, the=
 compiler "knows" the object will always be 32-bit aligned and generates as=
sembly based on this assumption. Of course this is incorrect if the lower l=
ayers didn't have a multiple of 4 bytes of headers.

Anyway, I discovered the hard way that there are lots and lots of places in=
 the IP code that assumes alignment, so this seems to be a rather daunting =
task to fix. So this patch will just be one very small piece of the puzzle.=
 :/

(Perhaps something for kernel newbies, to track down and fix all the alignm=
ent assumptions in the IP stack?)

Rgds
Pierre

--=_hera.drzeus.cx-32160-1192959221-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFHGx0O7b8eESbyJLgRAmJSAKCvy12z7nfjzsA0w5KxQgyu0GHs/wCgqGE5
LhFNkdarfEpkIYsoBXx57o4=
=0F8F
-----END PGP SIGNATURE-----

--=_hera.drzeus.cx-32160-1192959221-0001-2--

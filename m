From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: net: alignment problem in icmp code
Date: Mon, 22 Oct 2007 10:42:08 +0200
Message-ID: <20071022104208.78c79467@poseidon.drzeus.cx>
References: <20071022065443.2f3c1b8a@poseidon.drzeus.cx>
	<20071021.221524.49830652.davem@davemloft.net>
	<20071022092350.5c75b3bd@poseidon.drzeus.cx>
	<20071022.013105.74746322.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=PGP-SHA1; boundary="=_hera.drzeus.cx-19617-1193042499-0001-2"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.drzeus.cx ([85.8.24.16]:32830 "EHLO smtp.drzeus.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751879AbXJVImR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 04:42:17 -0400
In-Reply-To: <20071022.013105.74746322.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_hera.drzeus.cx-19617-1193042499-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 22 Oct 2007 01:31:05 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

>=20
> On fast paths we aren't going to add things like get_unaligned()
> calls.
>=20
> Every architecture should handle unaligned accesses properly, and for
> the fast paths the network driver should provide the packet fully
> aligned or take steps to make it so if it can't DMA directly into
> 2-byte offset buffers (such as copying the packet).
>=20

This seems like a rather evil layering violation. The hardware driver needs=
 to be aware of every layer between itself and the IP stack for this to wor=
k. And what does "aligned" mean in this context? 32-bit aligned? 64-bit ali=
gned? The entire thing is severely underdocumented (which is why I got hit =
by the problem in the first place).

Also, since I developed the code on a forgiving platform (x86), I didn't no=
tice this requirement. Perhaps a WARN_ON(NET_IP_ALIGN && (skb->data & 0x3))=
;?

> What is the specific reason why you see packet headers unaligned?
> It's probably just some AVR networking driver that needs tweaks.

It's my own driver (if_sdio for libertas), which did not reserve two bytes =
as that voodoo was unknown to me.

Rgds
Pierre

--=_hera.drzeus.cx-19617-1193042499-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFHHGJh7b8eESbyJLgRAjaoAKCE+QCu3hc4eg6PyXIBUnMY7gb9nACg3lg3
8IfQI6HU9f2ON8yhhZa1kgs=
=aY7J
-----END PGP SIGNATURE-----

--=_hera.drzeus.cx-19617-1193042499-0001-2--

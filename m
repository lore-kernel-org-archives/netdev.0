From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [RFC PATCH] net: add dataref destructor to sk_buff
Date: Mon, 16 Nov 2009 09:22:57 -0500
Message-ID: <4B016041.5030000@gmail.com>
References: <4AF98A8C.9040201@novell.com>	<20091114011229.GA18580@gondor.apana.org.au>	<4AFE08EF.2030308@gmail.com> <20091113.190438.78469912.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigCA38B29347E8D8DB8FE10837"
Cc: herbert@gondor.apana.org.au, ghaskins@novell.com, mst@redhat.com,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:17285 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752985AbZKPOW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 09:22:58 -0500
In-Reply-To: <20091113.190438.78469912.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigCA38B29347E8D8DB8FE10837
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

David Miller wrote:
> From: Gregory Haskins <gregory.haskins@gmail.com>
> Date: Fri, 13 Nov 2009 20:33:35 -0500
>=20
>> Well, not with respect to the overall protocol, of course not.  But wi=
th
>> respect to the buffer in question, it _has_ to be.  Or am I missing
>> something?
>=20
> sendfile() absolutely, and positively, is not.
>=20
> Any entity can write to the pages being send via sendfile(), at will,
> and those writes will show up in the packet stream if they occur
> before the NIC DMA's the memory backed by those pages into it's
> buffer.

Right, understood.

>=20
> There is zero data synchronization whatsoever, we don't lock the
> pages, we don't block their usage while they are queued up in the
> socket send queue, nothing like that.

Understood.

>=20
> The user returns long before it every hits the wire and there is zero
> "notification" to the user that the pages in question for the
> sendfile() request are no longer in use.

Ok, this was the part I didn't know.

>=20
> It seems that your understanding of how buffering and synchronization
> works in the TCP stack has come out of a fairy tale :-)

I understand that we do not protect the buffers from modification from
other entities in process.  This was purely a question of
synchronization from the producers standpoint.

IOW:

for (;;) {
   char buf[512];

   memcpy(buf, next, sizeof(buf));=09
   write(fd, buf);
}

would work without worrying that the producer will stomp on buf itself.
 It is now my understanding that for things other than sendfile, this
works because the buffer is copied before it returns control to the app.
 For sendfile(), the producer is more or less on its own and therefore
has to be careful if they are reusing previous mmapped buffers.  Ok.

But really, this is somewhat orthogonal to the original problem, so let
me see if we can bring it back on topic.  Michael stated that this patch
in question may be problematic because there are places in the stack
that can get_page() without also maintaining a reference to the shinfo
object.  Evgeniy seems to say the opposite.  I am not sure who is right,
or if I misunderstood one or both of them.  Any thoughts?

Kind Regards,
-Greg



--------------enigCA38B29347E8D8DB8FE10837
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAksBYEEACgkQP5K2CMvXmqHRGACdHQBE2RI72HYNcNyDOivQjdHE
AXYAn3W9cRcV1O1Cu918l6ibruhrmNP1
=eH7w
-----END PGP SIGNATURE-----

--------------enigCA38B29347E8D8DB8FE10837--

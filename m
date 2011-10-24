From: Dan Siemon <dan@coverfire.com>
Subject: Re: [PATCH] cls_flow: Add tunnel support to the flow classifier
Date: Sun, 23 Oct 2011 21:21:26 -0400
Message-ID: <1319419287.20602.21.camel@ganymede>
References: <1318806373.7169.35.camel@ganymede>
	 <1318833623.2500.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-lApaNl+PCDBrCudpUy2q"
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.coverfire.com ([69.41.199.58]:51581 "EHLO
	alpha.coverfire.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752541Ab1JXBV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2011 21:21:29 -0400
In-Reply-To: <1318833623.2500.45.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-lApaNl+PCDBrCudpUy2q
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-10-17 at 08:40 +0200, Eric Dumazet wrote:
> Le dimanche 16 octobre 2011 =C3=A0 19:06 -0400, Dan Siemon a =C3=A9crit :
> > When used on an interface carrying tunneled traffic the flow classifier
> > can't look into the tunnels so all of the traffic within the tunnel is
> > treated as a single flow. This does not allow any type of intelligent
> > queuing to occur. This patch adds new keys to the flow classifier which
> > look inside the tunnel. Presently IP-IP, IP-IPv6, IPv6-IPv6 and IPv6-IP
> > tunnels are supported.
> >=20
> > If you are interested I have posted some background and experimental
> > results at:
> > http://www.coverfire.com/archives/2011/10/16/making-the-linux-flow-clas=
sifier-tunnel-aware/
> >=20
> > The related iproute2 patch can be found at the above URL as well.
> >=20
> > Signed-off-by: Dan Siemon <dan@coverfire.com>
> >=20
>=20
> Hi Dan
>=20
> You're adding a lot of code (omitting the diffstat :( ) for a specific
> usage, yet GRE tunnels are not supported.

Thanks for the review.

Are you arguing this use case isn't worth addressing or that there is a
more efficient way to implement this with less code?

> IPv6 part is also a bit limited : It assumes TCP/UDP headers are the
> first ones. Maybe its time to use ipv6_skip_exthdr() ?

I noticed this too but the existing src-proto and dst-proto don't handle
this case either. Maybe I can look into fixing those as well.

> Note also that if we pull (with pskb_network_may_pull()) too many bytes,
> we kill routing performance on paged frags devices, wich are now
> becoming very common.

I don't know what paged frag devices means but I trust you are correct :)

The existing keys also use pskb_network_may_pull(). Should they be changed =
as well?

> Adding tunnel support and deep packet inspection might require the use
> of skb_header_pointer() wich does the copy of needed data without
> requiring expensive reallocation of skb head.

I'll look into this but it may be a while before I have an updated
patch.

--=-lApaNl+PCDBrCudpUy2q
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCAAGBQJOpL2WAAoJEJKXGLoTP2w+RQoQAJ7gkGpdUTBaod9WGjn4XRjG
zA+q9kGabBqCkvGVQGNJMPM31WdrGicK97ReG8xIo5CWQHsPqZxOKxowojRUvRaX
cwsaJTdFT4PWE4zacFVREAK7MqQRqRJpRQBegOxalmlLUQVTn7S4prqSxBzczb3a
mWFVgK7425Lpxu1Kzb21pOn3kns3Tz90pFdatFw+S4TeO8lQRBQ3kzn0Qz6XKLfO
NHGmOwWt7tXuv9b/M+uRZ/bPPzPCipkEYvNyJMA5XQUBvYk5yBcOGnBjKA54ABtx
rovwEBWkXOFQzB4G1HW7CG3r48KMqZ5HwFGEWHLh11OMwzA2ftYYeSwlKPefOR9/
t15jJCjQY4qvVyyxpFdCUq0MUNzdlczhgTMQQm+/zcqZgeEDU0zVrYRcJzzOe3o0
TxIOOZOXcqolc+JxFhGaZCMjnFKuk34Sv5346N2KNN+bOaf96YK7UpWlV7UhriH8
+JwviodhWemmjj7ZL641b0F4p+hEBgjTw5g8GCeXq/7e1OEUw1HVl3NTAvL97m3k
BrZlfXDkWUyA5TqCa83z+UCenASv9Z7FqCPB34ZRX6UDomZmzoJhigGF9o70JSEP
z2wK0KyEaTSQ+GWhcaSb+RgobSMCL5jI9Z9W7bv/hEUvzgqKp6f8+gacSfohAf9H
OQ7zIYc73r4XZPP+FJ2q
=+3Ns
-----END PGP SIGNATURE-----

--=-lApaNl+PCDBrCudpUy2q--

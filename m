From: Volker Lendecke <Volker.Lendecke@SerNet.DE>
Subject: Re: maximum buffer size for splice(2) tcp->pipe?
Date: Wed, 14 Jan 2009 08:40:08 +0100
Message-ID: <E1LN0MC-00DaJs-M2@intern.SerNet.DE>
References: <E1LKrp3-004Tub-IR@intern.SerNet.DE> <20090113123702.ad29cd13.akpm@linux-foundation.org> <496D2078.9080302@cosmosbay.com>
Reply-To: Volker.Lendecke@SerNet.DE
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wac7ysb48OaltWcw"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Steven French <sfrench@us.ibm.com>,
	Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760099AbZANHkc@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <496D2078.9080302@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 14, 2009 at 12:15:04AM +0100, Eric Dumazet wrote:
> Volker, your splice() is a blocking one, from tcp socket to a pipe ?

Yes, it is.

> If no other thread is reading the pipe, then you might block forever
> in splice_to_pipe() as soon pipe is full (16 pages).

Why does it block when the pipe is full? Why doesn't it
return a short read, just like the read(2) call does? We
need to cope with that behaviour anyway.

> As pages are not necessarly full (each skb will use at least one page, ev=
en if=20
> its length is small), it is not really possible to use splice() like this.
>=20
> In your case, only safe way with current kernel would be to call splice()
> asking for no more than 16 bytes, that would be really insane for your ne=
eds.
>=20
> You may prefer a non blocking mode, at least when calling splice_to_pipe()

Which fd do I have to set the nonblocking flag on? The TCP
socket I read from, or the pipe I write to?

Thanks for the hint anyway :-)

Volker

--wac7ysb48OaltWcw
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFJbZbXbsgDfmnSbrYRAsruAJ9LsFBmZe0ujTclxWLT4YJi02RW5QCdHJhH
z/AdX1fcqLIvALxDMdaPUsI=
=G6NX
-----END PGP SIGNATURE-----

--wac7ysb48OaltWcw--

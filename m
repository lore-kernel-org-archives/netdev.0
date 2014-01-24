From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH 2/2] netxen: Add sanity checks for Rx buffers returning
 from hardware
Date: Fri, 24 Jan 2014 16:21:26 +1100
Message-ID: <20140124052126.GB4361@voom.redhat.com>
References: <1387257753-18676-1-git-send-email-david@gibson.dropbear.id.au>
 <1387257753-18676-3-git-send-email-david@gibson.dropbear.id.au>
 <20131219.150527.1753716895684393783.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="c3bfwLpm8qysLVxt"
Cc: manish.chopra@qlogic.com, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com, netdev@vger.kernel.org,
	snagarka@redhat.com, tcamuso@redhat.com, vdasgupt@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:46661 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751116AbaAXFVj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jan 2014 00:21:39 -0500
Content-Disposition: inline
In-Reply-To: <20131219.150527.1753716895684393783.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--c3bfwLpm8qysLVxt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Dec 19, 2013 at 03:05:27PM -0500, David Miller wrote:
> From: David Gibson <david@gibson.dropbear.id.au>
> Date: Tue, 17 Dec 2013 16:22:33 +1100
>=20
> > +static int netxen_check_rx_buf(int index, struct netxen_rx_buffer *rxb=
uf)
> > +{
> > +	int ret =3D 0;
> > +
> > +	if ((rxbuf->list.next !=3D LIST_POISON1)
> > +	    || (rxbuf->list.prev !=3D LIST_POISON2)) {
> > +		printk(KERN_ERR "netxen: Rx buffer is already on free list "
> > +		       "(next=3D%p, prev=3D%p)\n", rxbuf->list.next,
> > +		       rxbuf->list.prev);
> > +		ret =3D -1;
> > +	}
>=20
> First, you should be using netdev_err() or similar.

Well, I was just matching the form used in the rest of the driver.

> Second, doing this unconditionally for every receive packet is
> not really reasonable.

Yeah, trouble is I don't know what the alternative is.  Whatever is
causing this problem, it's triggered very rarely - I'm only seeing a
pattern by looking across everything reported by Red Hat customers.
Just adding diagnostics for one customer is unlikely to be useful,
because the chances are they'll never hit the bug again.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--c3bfwLpm8qysLVxt
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJS4fhWAAoJEGw4ysog2bOSvG0P/2ngrNQeo2sIjZvf/1AKL5bv
1G7eOWRSk4AlHuopAXQQImqHSURN/yM3Y2z2F1uYn7ntJzlBz6x3kIrhK7h7rgNq
Y7bcLij9RQeq8aP0pzqeK3TpOZ1OL2Enbb3gzbw7MwvMFZ434lq6q2Bi1ULiktWE
cNJ4XauAgZfHVH+1InR0q4nAZeH1RFZtn/feFIbqnHHOckCadZiZDDkoYCcoLzfH
hOQD02Fp+8B1T4Sbu3p5Pfx7AEwacIi+Ne5zkKLSaCrVir4wkT+iydEBNUszvunb
92GJOmo1t9Uq4eGME2ckLqB1Y5OYE0HWAoPROiuZSmzwDIOo0slUK7rhAThY650J
DdyfFtV1kYsJarudQBga7iIhwdSXYxjaU/WcYQfEXMPf8igHkD1WXRAWMKjxgK83
Bk+6nnamF372rCk2wexH4LxS6Yv4QL5WfADDe3N8k8dgI0DHm9y8toSXbL5ffise
jSJWZVMFeBsRs1VUqpnrVYqZ+2l0pL8MzPZvPekmDOIEI2jCP2X118HZQ+ZUl3os
ypM/F2aihZfY7CZsuHLhGXbdSojX0BMNm9n793ARZM/6H7MCdTGiiwgRL+ZlOVhX
JsDoSFib4TGdj3NvZYDJ6MUyPuHNJtYzTCzqrWEtR6PHp9ox7VJL18KBRiR3VX+v
eMWHiYHitK0mSOAPD4vT
=aXzL
-----END PGP SIGNATURE-----

--c3bfwLpm8qysLVxt--

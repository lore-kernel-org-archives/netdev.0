From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net 1/8] igb: Update queue reinit function to call dev_close
 when init of queues fails
Date: Fri, 29 Nov 2013 23:52:26 -0800
Message-ID: <1385797946.2248.64.camel@jtkirshe-mobl>
References: <1385624162-10116-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1385624162-10116-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20131129.154757.2160926223289559260.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-uMXUHQTjdJQWzm7GJNoM"
Cc: carolyn.wyborny@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27506 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750955Ab3K3Hwg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Nov 2013 02:52:36 -0500
In-Reply-To: <20131129.154757.2160926223289559260.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-uMXUHQTjdJQWzm7GJNoM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-11-29 at 15:47 -0500, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Wed, 27 Nov 2013 23:35:55 -0800
>=20
> > From: Carolyn Wyborny <carolyn.wyborny@intel.com>
> >=20
> > This patch adds a call to dev_close if the queue reinit fails in order
> > to make clearer to the user that the device is down.
> >=20
> > Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
> > Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
> This is a very bad approach to this problem.
>=20
> Users absolutely do not expect their entire interface to go down
> simply because an ethtool request cannot be satisfied.  This is
> extremely poor quality of implementation.
>=20
> And in this specific case it absolutely is not necessary.
>=20
> The only thing that can fail is the queue allocation, so make a
> function which can preserve the previous configuration if the queue
> allocation fails.  How about "igb_reinit_interrupt_scheme".
>=20
> Don't free the q vectors until the very last moment, when you know
> that the allocation of the new q vectors has succeeded.
>=20
> I'm not applying this patch, it needs to be reimplemented more
> sanely, using the above suggestions or similar.
>=20
> Thanks.

Thanks for the feedback Dave, I will drop this patch from the series so
that Carolyn can re-work the solution.

--=-uMXUHQTjdJQWzm7GJNoM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSmZk6AAoJEOVv75VaS+3O2x0P/A9KtrnKHn8Yx4AjhYYXjy3n
mgJtUodkw6TcazZc75iOSjmblGDz1r9MzRcfgVIo55HtlmHlVA4V2/XVdZxepJPQ
VYPVYErO/hKVLs0USJlYSkabXkYGD916MBH19qQCijTis8Oe18ExGF5nIEmyr0Wq
kVFxthVLQmMm1gqDZzoQ15/VZ7A8Nr2x2hdoObXPohooQ/Ul0P4eaIie53P6VxyJ
lDQ9kI7gDn0s3Lr8lbuUAzY/OyNUlkSwck30Raqv5fvO/wJUmrFvmk35aRm/3TlR
BLdjWCpKKD20hlDU90qTR55OQQcDH2+/Euij/KtLMb7Bazvgt84ZjGG5gSxi06if
b0gWJLC3Wf6z5Mh5Z9Njj1GzJy8Rhl2pxBfP3PLX8oKd1/XKZsKJLYV1Chjzpeck
9IA3KpS2htLGDoq1rlRYSFFOo0qPdZkJBRj5mIRZGE+ub60cqOoODtooGMTKIRFa
WZi8YVGv3ZT8Oc9h9D//nDfwsV7PDSmB+g/YehljnKVe6kllmhdSXEohxVDKcLIa
tMr9e1z/quORM/C6DS4+5rzIMrN4oNENj6BZgUGjaRJvvLhVBn/GJHukwJ/U2ik3
xZ4CSP9+nsvnrU36PMfH8V7zYScTMLPmN28tfIw5GjmcFW0nY1YYpoTFYJLwkP1z
Fr4/Yn+l0JMqIQHb9BRx
=SGIq
-----END PGP SIGNATURE-----

--=-uMXUHQTjdJQWzm7GJNoM--

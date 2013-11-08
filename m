From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH 2/2] ixgbe: deleting dfwd stations out of order
 can cause null ptr deref
Date: Fri, 08 Nov 2013 04:36:34 -0800
Message-ID: <1383914194.2365.31.camel@jtkirshe-mobl>
References: <20131108084654.6935.36501.stgit@nitbit.x32>
	 <20131108085109.6935.99661.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-38pABYTUYnXBy/URzshb"
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:13887 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757103Ab3KHMgi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Nov 2013 07:36:38 -0500
In-Reply-To: <20131108085109.6935.99661.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-38pABYTUYnXBy/URzshb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-11-08 at 00:51 -0800, John Fastabend wrote:
> The number of stations in use is kept in the num_rx_pools counter
> in the ixgbe_adapter structure. This is in turn used by the queue
> allocation scheme to determine how many queues are needed to support
> the number of pools in use with the current feature set.
>=20
> This works as long as the pools are added and destroyed in order
> because (num_rx_pools * queues_per_pool) is equal to the last
> queue in use by a pool. But as soon as you delete a pool out of
> order this is no longer the case. So the above multiplication
> allocates to few queues and a pool may reference a ring that has
> not been allocated/initialized.
>=20
> To resolve use the bit mask of in use pools to determine the final
> pool being used and allocate enough queues so that we don't
> inadvertently remove its queues.
>=20
> # ip link add link eth2 \
>         numtxqueues 4 numrxqueues 4 txqueuelen 50 type macvlan
> # ip link set dev macvlan0 up
> # ip link add link eth2 \
>         numtxqueues 4 numrxqueues 4 txqueuelen 50 type macvlan
> # ip link set dev macvlan1 up
> # for i in {0..100}; do
>   ip link set dev macvlan0 down; ip link set dev macvlan0 up;
>   done;
>=20
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-38pABYTUYnXBy/URzshb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSfNrSAAoJEOVv75VaS+3OOhAQAIz8QV9fLsmnk3GS4Y2YigjY
yp/KmSwBjJ7br+3tEcSEoxLNZEVTkcR3NPmico6DyTh/1O9wCKkVF+C8zDWxTMP5
BT0t6Mzy5rO/1ilaDMBuE125YnpY5U0a58JkEy7Axwa0WHSbSNSLdVjnMOsKPcFG
mfqwzpaEcN3/ThBD2zdkpR7HFC4yE4poEUYt9ilYjiJisZtsxpEByrV2+r6G19XK
FDySx/D/x/DQLm1VN7Ew7ST9Sbpdnf4seX/ZIxxuJ99gwlsQrQYWlQQE6WmbQcrh
rK9t80tLCn1sgh/46rZPZEzfpg7jl02UZdOa1tUfID6QhtRv4e2llZWADXmO5kMB
AhCQITEH7tT50nGIu/hXXWq2wzc9MtvF7yos8AOSj5S/7NvUGQkLmLnsVnnMDwda
PUTTpEO7yoKf0sGCRN2TuBoEHoiHUh1wiGNLzuuAo3s/GaXHmVWmbgwl266iw214
hDHWeC1D0oD50F8Qt/YyNHoe/fnVCDIFJPIaENFQRqdRSDSS3QGIFYKO4O1qSBsg
7O0gikx7vqdgjbRch6FJ+xiXd3OQMontFZ8XTHY8Jrc9sLuQTzPShsQHzkOJYxcm
CI7Y3P0kAQsr9DhJrvkhbzatRHfJ1E7npA6iDUsZ6MBGYVbcrYC3wUlIvlHTc3tL
4a5T1KOg4PDGIL0h6loY
=D6VO
-----END PGP SIGNATURE-----

--=-38pABYTUYnXBy/URzshb--

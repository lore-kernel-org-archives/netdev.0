From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [next-queue PATCH 1/3] i40e/i40evf: Add support for GSO partial
 with UDP_TUNNEL_CSUM and GRE_CSUM
Date: Fri, 08 Apr 2016 23:51:00 -0700
Message-ID: <1460184660.2982.1.camel@intel.com>
References: <20160408210103.13096.77973.stgit@ahduyck-xeon-server>
	 <20160408210641.13096.8972.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-dCTzm0CcYIBB9lTvWoQA"
To: Alexander Duyck <aduyck@mirantis.com>, herbert@gondor.apana.org.au,
	tom@herbertland.com, jesse@kernel.org, alexander.duyck@gmail.com,
	edumazet@google.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:45037 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751987AbcDIGvO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Apr 2016 02:51:14 -0400
In-Reply-To: <20160408210641.13096.8972.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-dCTzm0CcYIBB9lTvWoQA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-04-08 at 17:06 -0400, Alexander Duyck wrote:
> This patch makes it so that i40e and i40evf can use GSO_PARTIAL to
> support
> segmentation for frames with checksums enabled in outer headers.=C2=A0 As
> a
> result we can now send data over these types of tunnels at over
> 20Gb/s
> versus the 12Gb/s that was previously possible on my system.
>=20
> The advantage with the i40e parts is that this offload is mostly
> transparent as the hardware still deals with the inner and/or outer
> IPv4
> headers so the IP ID is still incrementing for both when this offload
> is
> performed.
>=20
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_main.c=C2=A0=C2=A0=C2=A0=C2=A0=
 |=C2=A0=C2=A0 10 ++++++++--
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_txrx.c=C2=A0=C2=A0=C2=A0=C2=A0=
 |=C2=A0=C2=A0=C2=A0 7 ++++++-
> =C2=A0drivers/net/ethernet/intel/i40evf/i40e_txrx.c=C2=A0=C2=A0 |=C2=A0=
=C2=A0=C2=A0 7 ++++++-
> =C2=A0drivers/net/ethernet/intel/i40evf/i40evf_main.c |=C2=A0=C2=A0 10 ++=
++++++--
> =C2=A04 files changed, 28 insertions(+), 6 deletions(-)

Dropping this patch because it does not even compile...

[23:49:07 @jtkirshe-linux:next-queue]$ make -j 77 -s
Makefile:679: Cannot use CONFIG_KCOV: -fsanitize-coverage=3Dtrace-pc is
not supported by compiler
=C2=A0 DESCEND=C2=A0=C2=A0objtool
drivers/net/ethernet/intel/i40evf/i40evf_main.c: In function
=E2=80=98i40evf_process_config=E2=80=99:
drivers/net/ethernet/intel/i40evf/i40evf_main.c:2354:8: error:
=E2=80=98NETIF_F_GSO_PARTIAL=E2=80=99 undeclared (first use in this functio=
n)
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0NETIF_F_GSO_PARTIAL=C2=A0=
=C2=A0|
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^
drivers/net/ethernet/intel/i40evf/i40evf_main.c:2354:8: note: each
undeclared identifier is reported only once for each function it
appears in
drivers/net/ethernet/intel/i40evf/i40evf_main.c:2361:9: error: =E2=80=98str=
uct
net_device=E2=80=99 has no member named =E2=80=98gso_partial_features=E2=80=
=99
=C2=A0=C2=A0=C2=A0netdev->gso_partial_features |=3D NETIF_F_GSO_UDP_TUNNEL_=
CSUM;
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^
drivers/net/ethernet/intel/i40evf/i40evf_main.c:2363:8: error: =E2=80=98str=
uct
net_device=E2=80=99 has no member named =E2=80=98gso_partial_features=E2=80=
=99
=C2=A0 netdev->gso_partial_features |=3D NETIF_F_GSO_GRE_CSUM;
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^
drivers/net/ethernet/intel/i40evf/i40evf_main.c:2367:6: error:
=E2=80=98NETIF_F_TSO_MANGLEID=E2=80=99 undeclared (first use in this functi=
on)
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0NETIF_F_TSO_MANGLEID;
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^
drivers/net/ethernet/intel/i40evf/i40e_txrx.c: In function =E2=80=98i40e_ts=
o=E2=80=99:
drivers/net/ethernet/intel/i40evf/i40e_txrx.c:1573:37: error:
=E2=80=98SKB_GSO_PARTIAL=E2=80=99 undeclared (first use in this function)
=C2=A0=C2=A0=C2=A0if (!(skb_shinfo(skb)->gso_type & SKB_GSO_PARTIAL) &&
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^
drivers/net/ethernet/intel/i40evf/i40e_txrx.c:1573:37: note: each
undeclared identifier is reported only once for each function it
appears in
drivers/net/ethernet/intel/i40evf/i40e_txrx.c: In function
=E2=80=98i40e_tx_enable_csum=E2=80=99:
drivers/net/ethernet/intel/i40evf/i40e_txrx.c:1711:37: error:
=E2=80=98SKB_GSO_PARTIAL=E2=80=99 undeclared (first use in this function)
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0!(skb_shinfo(skb)->gso_type & SKB=
_GSO_PARTIAL) &&
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^
scripts/Makefile.build:291: recipe for target
'drivers/net/ethernet/intel/i40evf/i40evf_main.o' failed
make[5]: *** [drivers/net/ethernet/intel/i40evf/i40evf_main.o] Error 1
make[5]: *** Waiting for unfinished jobs....
scripts/Makefile.build:291: recipe for target
'drivers/net/ethernet/intel/i40evf/i40e_txrx.o' failed
make[5]: *** [drivers/net/ethernet/intel/i40evf/i40e_txrx.o] Error 1
scripts/Makefile.build:440: recipe for target
'drivers/net/ethernet/intel/i40evf' failed
make[4]: *** [drivers/net/ethernet/intel/i40evf] Error 2
make[4]: *** Waiting for unfinished jobs....
drivers/net/ethernet/intel/i40e/i40e_main.c: In function
=E2=80=98i40e_config_netdev=E2=80=99:
drivers/net/ethernet/intel/i40e/i40e_main.c:9127:8: error:
=E2=80=98NETIF_F_GSO_PARTIAL=E2=80=99 undeclared (first use in this functio=
n)
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0NETIF_F_GSO_PARTIAL=C2=A0=
=C2=A0|
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^
drivers/net/ethernet/intel/i40e/i40e_main.c:9127:8: note: each
undeclared identifier is reported only once for each function it
appears in
drivers/net/ethernet/intel/i40e/i40e_main.c:9134:9: error: =E2=80=98struct
net_device=E2=80=99 has no member named =E2=80=98gso_partial_features=E2=80=
=99
=C2=A0=C2=A0=C2=A0netdev->gso_partial_features |=3D NETIF_F_GSO_UDP_TUNNEL_=
CSUM;
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^
drivers/net/ethernet/intel/i40e/i40e_main.c:9136:8: error: =E2=80=98struct
net_device=E2=80=99 has no member named =E2=80=98gso_partial_features=E2=80=
=99
=C2=A0 netdev->gso_partial_features |=3D NETIF_F_GSO_GRE_CSUM;
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^
drivers/net/ethernet/intel/i40e/i40e_main.c:9140:6: error:
=E2=80=98NETIF_F_TSO_MANGLEID=E2=80=99 undeclared (first use in this functi=
on)
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0NETIF_F_TSO_MANGLEID;
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^
scripts/Makefile.build:291: recipe for target
'drivers/net/ethernet/intel/i40e/i40e_main.o' failed
make[5]: *** [drivers/net/ethernet/intel/i40e/i40e_main.o] Error 1
make[5]: *** Waiting for unfinished jobs....
drivers/net/ethernet/intel/i40e/i40e_txrx.c: In function =E2=80=98i40e_tso=
=E2=80=99:
drivers/net/ethernet/intel/i40e/i40e_txrx.c:2308:37: error:
=E2=80=98SKB_GSO_PARTIAL=E2=80=99 undeclared (first use in this function)
=C2=A0=C2=A0=C2=A0if (!(skb_shinfo(skb)->gso_type & SKB_GSO_PARTIAL) &&
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^
drivers/net/ethernet/intel/i40e/i40e_txrx.c:2308:37: note: each
undeclared identifier is reported only once for each function it
appears in
drivers/net/ethernet/intel/i40e/i40e_txrx.c: In function
=E2=80=98i40e_tx_enable_csum=E2=80=99:
drivers/net/ethernet/intel/i40e/i40e_txrx.c:2488:37: error:
=E2=80=98SKB_GSO_PARTIAL=E2=80=99 undeclared (first use in this function)
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0!(skb_shinfo(skb)->gso_type & SKB=
_GSO_PARTIAL) &&
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^
scripts/Makefile.build:291: recipe for target
'drivers/net/ethernet/intel/i40e/i40e_txrx.o' failed
make[5]: *** [drivers/net/ethernet/intel/i40e/i40e_txrx.o] Error 1
scripts/Makefile.build:440: recipe for target
'drivers/net/ethernet/intel/i40e' failed
make[4]: *** [drivers/net/ethernet/intel/i40e] Error 2
scripts/Makefile.build:440: recipe for target
'drivers/net/ethernet/intel' failed
make[3]: *** [drivers/net/ethernet/intel] Error 2
make[3]: *** Waiting for unfinished jobs....
scripts/Makefile.build:440: recipe for target 'drivers/net/ethernet'
failed
make[2]: *** [drivers/net/ethernet] Error 2
scripts/Makefile.build:440: recipe for target 'drivers/net' failed
make[1]: *** [drivers/net] Error 2
make[1]: *** Waiting for unfinished jobs....
Makefile:962: recipe for target 'drivers' failed
make: *** [drivers] Error 2
make: *** Waiting for unfinished jobs....
--=-dCTzm0CcYIBB9lTvWoQA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXCKZVAAoJEOVv75VaS+3O4SYP/AqG1W7FCAA62o3W2+fwDElz
zKB98rwtFbOwkaDcJH0HHQTus12yFnu/0VJJ72jK8/sPAuq4gy9CHmvCFkUBSNzy
856H21qy3jk5ekBEk73pGM5df8wLu6hbtScSgd4Z9MEPGb6PcZ7I95d6QrKSjOli
e4Y2bGvY88d5To8GPnM8FffxbJrEWBP/Wr18QoPulgA3N+vn7ayWCNFHuEjxGyrZ
XOTzWjeQsIxHKJM6fd+eoFoMDeOjqUTMnLu1rHo55Z7PHLRZUKg6Zu7o2MRqgEe5
PAhir8ocfhVpsUrd5yKPuP07lZA+noC43sdNAwHxQvAAZhzog47QILpIMA2rcGzV
cvXLkgW4gEdLv027qmYxB34i6NNl9PVvHTg/dQuBqtNJ22oKwKBOSqwgML3z/C+J
/b9R94jSbdX5n0EFmwkCF94aDIUrsCvhqnOGN5nz2n2KWpaUAj2C/JYHtIR1qhEy
WfV6hMEYICoekT3E5BLDiKHyP4fq/IeKL8CABXRj3SNY7M39iKtP9KImjViNi4jy
IRvm29HaoqHLn91NBcfjR6Y55O+KkQ7RqeOlbmcoLxV4zv3GSEFB/C92F3d8KxcF
8uPeHkbS4f/Q5PpEHznhhm5JaU5CJqULOoS6mGte2rUSJmuhWCh1i07nuDPq0ZJ7
VSdbi4+7D51HyZWtN9jF
=LZoU
-----END PGP SIGNATURE-----

--=-dCTzm0CcYIBB9lTvWoQA--

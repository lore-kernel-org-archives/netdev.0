From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH] net/pasemi: fix compiler warning
Date: Thu, 3 May 2012 10:51:46 +1000
Message-ID: <20120503105146.83f0a4a074dafad0443b875d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__3_May_2012_10_51_46_+1000_zjNGosqx.hAVI645"
Cc: Olof Johansson <olof@lixom.net>,
	"Pradeep A. Dalvi" <netdev@pradeepdalvi.com>,
	ppc-dev <linuxppc-dev@lists.ozlabs.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:35406 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753370Ab2ECAv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 20:51:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Thu__3_May_2012_10_51_46_+1000_zjNGosqx.hAVI645
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Fix this compiler warning (on PowerPC) by not marking a parameter as
const:

drivers/net/ethernet/pasemi/pasemi_mac.c: In function 'pasemi_mac_replenish=
_rx_ring':
drivers/net/ethernet/pasemi/pasemi_mac.c:646:3: warning: passing argument 1=
 of 'netdev_alloc_skb' discards qualifiers from pointer target type
include/linux/skbuff.h:1706:31: note: expected 'struct net_device *' but ar=
gument is of type 'const struct net_device *'

Cc: Olof Johansson <olof@lixom.net>
Cc: Pradeep A. Dalvi <netdev@pradeepdalvi.com>
Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ethernet/pasemi/pasemi_mac.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

The warning was introduced by commit dae2e9f430c4 ("netdev: ethernet
dev_alloc_skb to netdev_alloc_skb").

diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/etherne=
t/pasemi/pasemi_mac.c
index ddc95b0..e559dfa 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -623,7 +623,7 @@ static void pasemi_mac_free_rx_resources(struct pasemi_=
mac *mac)
 	mac->rx =3D NULL;
 }
=20
-static void pasemi_mac_replenish_rx_ring(const struct net_device *dev,
+static void pasemi_mac_replenish_rx_ring(struct net_device *dev,
 					 const int limit)
 {
 	const struct pasemi_mac *mac =3D netdev_priv(dev);
--=20
1.7.10.280.gaa39

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__3_May_2012_10_51_46_+1000_zjNGosqx.hAVI645
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPodajAAoJEECxmPOUX5FEpFUP/2OW0IF0jT7U9kd9n5piSJfJ
MCQIdjCcEpoVS6dCApdJ2hxLQA0ahn7ZLAYvr2YJk7COyidZpJY0Fu6TwBHu7cp2
PaY/6DpPT4yL2GZR3VqOe9kLXPgbpgpMbPT8DlAlMLnfB6wJ3cQecjp1Nv0V1CwB
UZgCGtwBUxiRiFBHEJ4dqSF1gei47xfWPB1r75GuCUwtB+2Lhrs7Z8lK86fs9xV8
HqsS/3YF2aNm0+N3+zwnCZO3sqgxo5YmxKzJx9+wyqpjFZw0BJwU5R54XdG27hoo
STfG209D39Vrm/gNj7cL6Q4aeVASgwrWbLI+Ej1r9TtzWp0X4+oUmQ5IsPwDscPI
1pjqwB1YWboIzcsOC/w6SNxGljaatgTYhudoJnPNJfQ+U90dcda82idosGvd1yrq
8R3ZkufidbJb/PtdDrr4lWbQDxdPfltWsu//u2+wFvt5c2iFyhjVpDX30B4a88Kn
Z6tbt2HjaCYZ6JigWYdpekLt+EgCS5P9Bh/fyPagzEpgqFRFUNRglC1UurAp5Po+
cQCMrDLX74Sl0bn5Jk9TIHwlVJrDeAPjSp3nTeJga83yubJlbGiMAsctcXB3c/da
Mg5nMwZFE9Rb3AzD8RSHZ6Hvq47jNqJnubA3/k+jOVcVdt5eT3RteGgKiDrReCZU
M/BkF326LHcsfW0FlHG8
=z+11
-----END PGP SIGNATURE-----

--Signature=_Thu__3_May_2012_10_51_46_+1000_zjNGosqx.hAVI645--

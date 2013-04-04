From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the wireless
 tree
Date: Thu, 4 Apr 2013 11:44:44 +1100
Message-ID: <20130404114444.de4e40c24f4e1a0e4c0b7328@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__4_Apr_2013_11_44_44_+1100_v3v+zd8ZXeCgqXdk"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	Gabor Juhos <juhosg@openwrt.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__4_Apr_2013_11_44_44_+1100_v3v+zd8ZXeCgqXdk
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/wireless/rt2x00/rt2x00pci.c between commit 69a2bac8984c
("rt2x00: rt2x00pci: fix build error on Ralink RT3x5x SoCs") from the
wireless tree and commit 1f9061d27d3d ("drivers:net: dma_alloc_coherent:
use __GFP_ZERO instead of memset(, 0)") from the net-next tree.

The former moved the code modified by the latter into a different file,
so I added the following merge fix patch and can carry the fix as
necessary (no action is required).

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 4 Apr 2013 11:42:05 +1100
Subject: [PATCH] drivers:net: fix up for code movement from rt2x00pci.c

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/wireless/rt2x00/rt2x00mmio.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2x00mmio.c b/drivers/net/wireles=
s/rt2x00/rt2x00mmio.c
index d84a680..9fe9a36 100644
--- a/drivers/net/wireless/rt2x00/rt2x00mmio.c
+++ b/drivers/net/wireless/rt2x00/rt2x00mmio.c
@@ -123,12 +123,10 @@ static int rt2x00pci_alloc_queue_dma(struct rt2x00_de=
v *rt2x00dev,
 	 */
 	addr =3D dma_alloc_coherent(rt2x00dev->dev,
 				  queue->limit * queue->desc_size,
-				  &dma, GFP_KERNEL);
+				  &dma, GFP_KERNEL | __GFP_ZERO);
 	if (!addr)
 		return -ENOMEM;
=20
-	memset(addr, 0, queue->limit * queue->desc_size);
-
 	/*
 	 * Initialize all queue entries to contain valid addresses.
 	 */
--=20
1.8.1

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__4_Apr_2013_11_44_44_+1100_v3v+zd8ZXeCgqXdk
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRXMz8AAoJEECxmPOUX5FExBIP/jewPg6JVgi3GQuJ5zp4GFmv
thlXnE13eSG/g5O3AiuMCM+QXwhtuWMTHUSn8KXLPqZQqur6QrTYYAtWUFKB3i6u
xTSlx8DU722PSEFhkbdIjnoeKBqFHatQrk4CWk2GRBFGdvpZjH+bzSlKvqYK49Dr
fYU6i/labWNTgpUY7apzdkFNuKmYRBrQmwZwGYNfMX4LLWkR61oMO6jzyNRFWj8f
G3zQqnc+8hzq9DkPzPcBS7/C3gWjOb4fZPfVsydYdwt6WGSPZ+lZdyxD00+n9MhH
gNQVaC1vkf6rkIs+24OHaK9l2seZz3B181CZr0n8JWkcBlSh3euOa+0B25+BJRZ6
0aZNA5RoDglwgKMDI9n2Qlcfm+5XalqVMMk9A/QvwHc84qO1uCTYqjV0XXklhapI
NZjcwvbay8o8FJ+q5L76SnbgGE8Ko5QI4Qndl87NzJvstbZarUkpm4ZZR/+FuBhW
Ih4KLMp/toeM5Rpy3DYFKIuOTC97IvYT45QWRunecUVGF9QIdi9oAKcqUeN9gJ0g
JIV8evPWGjvGf/+Aq31BusZFErKsmnweiJtPDSCb2aEVroM0HS5zjtHq8TxPx53e
rOjqeSqvNLlV6HAE7hHXFfljWWaV3adjmyq5opysYncH0pOZmdWR48kkdv2bUvj6
on2CSbvYhrrl0j8TJPBc
=9fJF
-----END PGP SIGNATURE-----

--Signature=_Thu__4_Apr_2013_11_44_44_+1100_v3v+zd8ZXeCgqXdk--

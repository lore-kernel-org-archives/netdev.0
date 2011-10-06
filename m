From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the staging tree with the net tree
Date: Thu, 6 Oct 2011 16:04:33 +1100
Message-ID: <20111006160433.44de2a1374b6ec4efc97e04e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__6_Oct_2011_16_04_33_+1100_XIAb135vYIODAlvJ"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ian Campbell <Ian.Campbell@citrix.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Mark Einon <mark.einon@gmail.com>
To: Greg KH <greg@kroah.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__6_Oct_2011_16_04_33_+1100_XIAb135vYIODAlvJ
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Greg,

Today's linux-next merge of the staging tree got a conflict in
drivers/staging/et131x/et1310_tx.c between commit bf3f1a6081aa ("et131x:
convert to SKB paged frag API") from the net tree and commit 10f00a49b048
("staging: et131x: Rename var name 'etdev' to 'adapter' throughout
module") from the staging tree.

I fixed it up (see below) and can carry the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/staging/et131x/et1310_tx.c
index 03e7a4e,2ecb934..0000000
--- a/drivers/staging/et131x/et1310_tx.c
+++ b/drivers/staging/et131x/et1310_tx.c
@@@ -519,12 -392,12 +392,12 @@@ static int nic_send_packet(struct et131
  			 * returned by pci_map_page() is always 32-bit
  			 * addressable (as defined by the pci/dma subsystem)
  			 */
 -			desc[frag++].addr_lo =3D
 -			    pci_map_page(adapter->pdev,
 -					 frags[i - 1].page,
 -					 frags[i - 1].page_offset,
 -					 frags[i - 1].size,
 -					 PCI_DMA_TODEVICE);
 +			desc[frag++].addr_lo =3D skb_frag_dma_map(
- 							&etdev->pdev->dev,
++							&adapter->pdev->dev,
 +							&frags[i - 1],
 +							0,
 +							frags[i - 1].size,
 +							PCI_DMA_TODEVICE);
  		}
  	}
 =20

--Signature=_Thu__6_Oct_2011_16_04_33_+1100_XIAb135vYIODAlvJ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJOjTbhAAoJEECxmPOUX5FEOg8P/R2VbR6MqtVIGuLAjk6238DO
swW5979xb0aZRJHFqQ8t/pl6c2AJMr0oyakNIwNaY2HpFq32Kqtf6yIo/K1STB8E
Tg2wCu2JSpEY68zJW8EHVEAypHz5WS0fFgS1xAnHz/jqyoFih59bhsgmV9Sxb8KK
QglqepjYGAXQHbjwDa19Kjg8H+zaGc9Janow9moX1YOLj3NvMTpiDDKaqsrDC7H9
/LZNEejEAszHx8eAubKpctAhCBqBBLf0QQYApVZBvab05Vvrvb/6/DNTLvv/8/IL
KlBvR5Vow5ckhSnpnm/8VOMOynsBiVQhfvp1x0G4Sz5hood3Ytsu6QegUAfzeUdh
CP6RsuaneV7GIYlDsS4uzv2d7p045edEPoDS+z1TX9obKY6PfMxyaiBDVKt0E0MK
TvxzyQuROCzPe1TWNS6iGvK6+M0hqBEF+CEcjOwZnd2JG0K2xrb83Uq8uusk5pKf
szDpBeYzhFLO+tBlf9YAuWpP7c6CBXhRI1edwUrhdsVPQ/2sNp14NHeeo+ZqBZnu
v6yzzWvEsuxa3AnAu0D/eUxIFzsXnn74pZPL2TJhSTiKU0o2kC0H9D/sPeshhPmo
AZHcLx0ubaME9m8UtHVAJ1PqqUEWYsWFvJmQaM5IuP5rBW+CLEDKD7Yv/+ffl584
kSC8keGoeiqu8GJkHWGd
=eTYo
-----END PGP SIGNATURE-----

--Signature=_Thu__6_Oct_2011_16_04_33_+1100_XIAb135vYIODAlvJ--

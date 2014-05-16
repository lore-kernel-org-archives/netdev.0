From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 16 May 2014 12:08:43 +1000
Message-ID: <20140516120843.1588995a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/4BksXgTKOA+AYXwC9syw5FG"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vince Bridgers <vbridgers2013@gmail.com>,
	Tobias Klauser <tklauser@distanz.ch>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/4BksXgTKOA+AYXwC9syw5FG
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got conflicts in
drivers/net/ethernet/altera/altera_msgdma.c and
drivers/net/ethernet/altera/altera_sgdma.c between commit 898305806ad5
("Altera TSE: Fix sparse errors and warnings") from the net tree and
commit d42f157b3498 ("Altera TSE: Remove unnecessary cast of void
pointers") from the net-next tree.

I fixed it up (mostly the former removed lines updated by the latter,
but see below) and can carry the fix as necessary (no action is
required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/altera/altera_sgdma.c
index 99cc56f451cf,dbd40e15b5cc..000000000000
--- a/drivers/net/ethernet/altera/altera_sgdma.c
+++ b/drivers/net/ethernet/altera/altera_sgdma.c
@@@ -179,11 -184,11 +179,10 @@@ void sgdma_clear_txirq(struct altera_ts
   */
  int sgdma_tx_buffer(struct altera_tse_private *priv, struct tse_buffer *b=
uffer)
  {
- 	struct sgdma_descrip __iomem *descbase =3D
- 		(struct sgdma_descrip __iomem *)priv->tx_dma_desc;
 -	int pktstx =3D 0;
 -	struct sgdma_descrip *descbase =3D priv->tx_dma_desc;
++	struct sgdma_descrip __iomem *descbase =3D priv->tx_dma_desc;
 =20
 -	struct sgdma_descrip *cdesc =3D &descbase[0];
 -	struct sgdma_descrip *ndesc =3D &descbase[1];
 +	struct sgdma_descrip __iomem *cdesc =3D &descbase[0];
 +	struct sgdma_descrip __iomem *ndesc =3D &descbase[1];
 =20
  	/* wait 'til the tx sgdma is ready for the next transmit request */
  	if (sgdma_txbusy(priv))
@@@ -240,13 -245,16 +239,12 @@@ void sgdma_add_rx_desc(struct altera_ts
   */
  u32 sgdma_rx_status(struct altera_tse_private *priv)
  {
- 	struct sgdma_descrip __iomem *base =3D
- 		(struct sgdma_descrip __iomem *)priv->rx_dma_desc;
 -	struct sgdma_csr *csr =3D priv->rx_dma_csr;
 -	struct sgdma_descrip *base =3D priv->rx_dma_desc;
 -	struct sgdma_descrip *desc =3D NULL;
 -	int pktsrx;
 -	unsigned int rxstatus =3D 0;
 -	unsigned int pktlength =3D 0;
 -	unsigned int pktstatus =3D 0;
++	struct sgdma_descrip __iomem *base =3D priv->rx_dma_desc;
 +	struct sgdma_descrip __iomem *desc =3D NULL;
  	struct tse_buffer *rxbuffer =3D NULL;
 +	unsigned int rxstatus =3D 0;
 =20
 -	u32 sts =3D ioread32(&csr->status);
 +	u32 sts =3D csrrd32(priv->rx_dma_csr, sgdma_csroffs(status));
 =20
  	desc =3D &base[0];
  	if (sts & SGDMA_STSREG_EOP) {
@@@ -348,11 -350,10 +346,10 @@@ static void sgdma_setup_descrip(struct=20
   */
  static int sgdma_async_read(struct altera_tse_private *priv)
  {
- 	struct sgdma_descrip __iomem *descbase =3D
- 		(struct sgdma_descrip __iomem *)priv->rx_dma_desc;
 -	struct sgdma_csr *csr =3D priv->rx_dma_csr;
 -	struct sgdma_descrip *descbase =3D priv->rx_dma_desc;
 -	struct sgdma_descrip *cdesc =3D &descbase[0];
 -	struct sgdma_descrip *ndesc =3D &descbase[1];
++	struct sgdma_descrip __iomem *descbase =3D priv->rx_dma_desc;
 +
 +	struct sgdma_descrip __iomem *cdesc =3D &descbase[0];
 +	struct sgdma_descrip __iomem *ndesc =3D &descbase[1];
 =20
  	struct tse_buffer *rxbuffer =3D NULL;
 =20

--Sig_/4BksXgTKOA+AYXwC9syw5FG
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTdXMwAAoJEMDTa8Ir7ZwV/WYP/ilpmsyS0lxqapK+65jpjDG5
kkCNcDDE7t0dTXchSRnXS4HSGT5OFoal7yxby+vVbeNg/81EOi3Rusudx+vEGL1N
LWwyNdrVETXr2WTve9uvjwqLb6/CiaXomkMibanEcN1BZkbTugdj7yqF0RPuCfcH
r4XCrh7qfnpD2lJaZ3a/3slJU1IaTldqt8EP4p/Jp2Mb0788Iv6QgWW1ybS638pC
qMsqc9eljSm4mX3A/zrk8vkIwdl4mBHxS45xKV5HBBmvk+FM7SSGEbh5mLbsz/Ef
6xQSLOBQIxM3KS5r5MUVshsZCA0a1wD2ImWT4lRGwQzMZDkMDEpKcpjO89Ew74T5
S2VKE+VVkMB0cYqcFFakubfZi3+GTNQk9OvOSf8/yyFsIFN5flK+MHizunJsmlue
4eYWLuEW+L/tUXvrZ3eKJ2u5UBlayvwSXdaf6RkhXUVRp/hDvsuWmADr42ntm7eE
avotMLLKNdgnrPfOrMLO7Cb2+EsXcU5fQJrbvjHp58IwbxRSNw/R8ooFzTxXqOTb
viBe7yp4hYaUE7Do3hzjRt1SLQ5PrKT5aF6khmc41TJeRloUicrLuCf7aQvOl7B6
jNTVKoH9f1QyircZ8OiPU+E110NIUjI1aConAlqgeOzxpSzh2Gp7mmZuQNsN/4ZZ
/WhRnETqLhUvkt8uf0xF
=cIHN
-----END PGP SIGNATURE-----

--Sig_/4BksXgTKOA+AYXwC9syw5FG--

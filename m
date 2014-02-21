From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the wireless
 tree
Date: Fri, 21 Feb 2014 13:34:41 +1100
Message-ID: <20140221133441.77e6ef11dfad31bb90a12d8a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__21_Feb_2014_13_34_41_+1100_L=If3W7cc/kR2ml3"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Amitkumar Karwar <akarwar@marvell.com>,
	Aaron Durbin <adurbin@chromium.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__21_Feb_2014_13_34_41_+1100_L=If3W7cc/kR2ml3
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/wireless/mwifiex/pcie.c between commit bb8e6a1ee881
("mwifiex: add NULL check for PCIe Rx skb") from the  tree and commit
dbccc92b5d54 ("mwifiex: balance dma map/unmap sizes") from the net-next
tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/mwifiex/pcie.c
index 7fe7b53fb17a,d11d4acf0890..000000000000
--- a/drivers/net/wireless/mwifiex/pcie.c
+++ b/drivers/net/wireless/mwifiex/pcie.c
@@@ -1211,15 -1217,7 +1217,13 @@@ static int mwifiex_pcie_process_recv_da
  		rd_index =3D card->rxbd_rdptr & reg->rx_mask;
  		skb_data =3D card->rx_buf_list[rd_index];
 =20
 +		/* If skb allocation was failed earlier for Rx packet,
 +		 * rx_buf_list[rd_index] would have been left with a NULL.
 +		 */
 +		if (!skb_data)
 +			return -ENOMEM;
 +
- 		MWIFIEX_SKB_PACB(skb_data, &buf_pa);
- 		pci_unmap_single(card->dev, buf_pa, MWIFIEX_RX_DATA_BUF_SIZE,
- 				 PCI_DMA_FROMDEVICE);
+ 		mwifiex_unmap_pci_memory(adapter, skb_data, PCI_DMA_FROMDEVICE);
  		card->rx_buf_list[rd_index] =3D NULL;
 =20
  		/* Get data length from interface header -

--Signature=_Fri__21_Feb_2014_13_34_41_+1100_L=If3W7cc/kR2ml3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTBrtFAAoJEMDTa8Ir7ZwVJ7QP/RVnuT9xAxC1BjeHRcl4rWRz
jo1+3HxM093AyfZDinbll7CaWejVU4zz9OvMMAoN3vK/BIzDfERTMh27TDMbWoUm
XlxbsgLO7ZU9x9btdELjrkzh7fpvtQ7cufpXOB2yEpVAOI/fxPN5QChKBFMBo3cv
3Qz6GBnCwOXWJAEzepDDFiOcyHmTUSKNwMbuqBRiOV/OmD0cs8rrJqCYvC5AKHN8
s7KidZEUEavT2ZwBsyzvN4t3u9oEykaXcrqV5WajSGkT1Rc66LWDkeURCyOnCKjB
Zr6gvEB+3xe4e5JZJQBSZxIPaKwX/BJGs0fWyrN311zh9vRgvAoBxnSk30XwyChj
yffttfLvkBbchcXMx4SOJJl35GuNObJ+ZMEqS7oZ19pIwUhnCzlmg5EdfRVSB5Te
xxTZvmmn6Ph5sFbbwkkX0X5TitO54hDvgX2jow1y7/St3geNeQt6CpfTNMLikIOi
QR8e4Ip9pzEhfh6X1lua0V8L0SMQahbUlLg/KED+EQyEQRJNL/bQNTvsNzVZYw/E
9xggp9uDw6feLrEvjyUME7RBJfUL+bXY1TStzclyVl1UiX+pYQi1L2qlGnlnFqKA
8UBC9bj+T//JRHGD9WE7FkeMLg5PMp94sEbjtXIvG4M2FixFmWZrzYNvdeTvvcu8
QX4eh38PZNDrn+zh9HeK
=3Dxu
-----END PGP SIGNATURE-----

--Signature=_Fri__21_Feb_2014_13_34_41_+1100_L=If3W7cc/kR2ml3--

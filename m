From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 25 Jun 2013 12:54:43 +1000
Message-ID: <20130625125443.fa0d462d854838c57f7b9abb@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__25_Jun_2013_12_54_43_+1000_8ahz79qvCquAdSdT"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__25_Jun_2013_12_54_43_+1000_8ahz79qvCquAdSdT
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/renesas/sh_eth.c between commit ca8c35852138
("sh_eth: fix unhandled RFE interrupt") from the net tree and commit
8f80899665c4 ("sh_eth: remove 'tx_error_check' field of 'struct
sh_eth_cpu_data'") from the net-next tree.

I fixed it up (I think - see below) and can carry the fix as necessary
(no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/renesas/sh_eth.c
index e29fe8d,7732f11..0000000
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@@ -380,10 -382,8 +382,9 @@@ static struct sh_eth_cpu_data r8a777x_d
  	.eesipr_value	=3D 0x01ff009f,
 =20
  	.tx_check	=3D EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
 -	.eesr_err_check	=3D EESR_TWB | EESR_TABT | EESR_RABT | EESR_RDE |
 -			  EESR_RFRMER | EESR_TFE | EESR_TDE | EESR_ECI,
 +	.eesr_err_check	=3D EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
 +			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE |
 +			  EESR_ECI,
- 	.tx_error_check	=3D EESR_TWB | EESR_TABT | EESR_TDE | EESR_TFE,
 =20
  	.apr		=3D 1,
  	.mpr		=3D 1,
@@@ -425,13 -414,11 +415,12 @@@ static struct sh_eth_cpu_data sh7724_da
 =20
  	.ecsr_value	=3D ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD,
  	.ecsipr_value	=3D ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | ECSIPR_ICDIP,
- 	.eesipr_value	=3D DMAC_M_RFRMER | DMAC_M_ECI | 0x01ff009f,
+ 	.eesipr_value	=3D 0x01ff009f,
 =20
  	.tx_check	=3D EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
 -	.eesr_err_check	=3D EESR_TWB | EESR_TABT | EESR_RABT | EESR_RDE |
 -			  EESR_RFRMER | EESR_TFE | EESR_TDE | EESR_ECI,
 +	.eesr_err_check	=3D EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
 +			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE |
 +			  EESR_ECI,
- 	.tx_error_check	=3D EESR_TWB | EESR_TABT | EESR_TDE | EESR_TFE,
 =20
  	.apr		=3D 1,
  	.mpr		=3D 1,
@@@ -480,11 -453,10 +455,11 @@@ static struct sh_eth_cpu_data sh7757_da
  	.rmcr_value	=3D 0x00000001,
 =20
  	.tx_check	=3D EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
 -	.eesr_err_check	=3D EESR_TWB | EESR_TABT | EESR_RABT | EESR_RDE |
 -			  EESR_RFRMER | EESR_TFE | EESR_TDE | EESR_ECI,
 +	.eesr_err_check	=3D EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
 +			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE |
 +			  EESR_ECI,
- 	.tx_error_check	=3D EESR_TWB | EESR_TABT | EESR_TDE | EESR_TFE,
 =20
+ 	.irq_flags	=3D IRQF_SHARED,
  	.apr		=3D 1,
  	.mpr		=3D 1,
  	.tpauser	=3D 1,
@@@ -595,11 -521,9 +524,9 @@@ static struct sh_eth_cpu_data sh7757_da
  	.eesipr_value	=3D DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
 =20
  	.tx_check	=3D EESR_TC1 | EESR_FTC,
 -	.eesr_err_check	=3D EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT | \
 -			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE | \
 -			  EESR_ECI,
 +	.eesr_err_check	=3D EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
 +			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
 +			  EESR_TDE | EESR_ECI,
- 	.tx_error_check	=3D EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_TDE | \
- 			  EESR_TFE,
  	.fdr_value	=3D 0x0000072f,
  	.rmcr_value	=3D 0x00000001,
 =20
@@@ -677,11 -579,9 +582,9 @@@ static struct sh_eth_cpu_data sh7734_da
  	.eesipr_value	=3D DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
 =20
  	.tx_check	=3D EESR_TC1 | EESR_FTC,
 -	.eesr_err_check	=3D EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT | \
 -			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE | \
 -			  EESR_ECI,
 +	.eesr_err_check	=3D EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
 +			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
 +			  EESR_TDE | EESR_ECI,
- 	.tx_error_check	=3D EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_TDE | \
- 			  EESR_TFE,
 =20
  	.apr		=3D 1,
  	.mpr		=3D 1,
@@@ -814,11 -643,9 +646,9 @@@ static struct sh_eth_cpu_data r8a7740_d
  	.eesipr_value	=3D DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
 =20
  	.tx_check	=3D EESR_TC1 | EESR_FTC,
 -	.eesr_err_check	=3D EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT | \
 -			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE | \
 -			  EESR_ECI,
 +	.eesr_err_check	=3D EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
 +			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
 +			  EESR_TDE | EESR_ECI,
- 	.tx_error_check	=3D EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_TDE | \
- 			  EESR_TFE,
 =20
  	.apr		=3D 1,
  	.mpr		=3D 1,

--Signature=_Tue__25_Jun_2013_12_54_43_+1000_8ahz79qvCquAdSdT
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRyQZ3AAoJEECxmPOUX5FEKXcP/066hTZc5TMDlmJdntbxrWiH
hhoAgJFrxtVHg5kvtXMLOdZ/a/7QLSg6Y5TLwEBEEsZldT2fwcmRiurY7P8h9zdw
V3JtaUiFPm4+GmgAqhsyGKzn0utqodVWnJCX9GCgVy47TMu77M3OAn30ZrobvWaW
ETcdpIx7L9vXjv3/DR1krgUc2phResjUFfAqcHuVVU75fbZo7Uc5XBxNBClmMiLe
VjEBQ7059RUI2mArY2nV3fwHl9HOlpjGSsAKdBhFhFDIKaajhHkIxIj8gHCgIgUJ
5exMZRtPHXygI/PmVtNOSam2qgbhVtkKos5rQUf4BsK0QsoR2NwnhHzNoW+FfrSq
7eUp0PC/By8asGBO8chP1g7W+sym3dw7GAQJvoYZLd8SYeHHOhY38wqu4hYKiqVE
+Qfjd+SVkmvPp6n055SXvV/n7OeV1MidkO2kKrnnv7YIGYDzvNg+KBWAwM2Psct9
re38nvr2HhdOyr2uX3T2FirqlhhXzw53WcLqj9zOMDYNFH238mHuAuy4lW1n5+iz
zf04UlKNlL68V0Ss5+CRxSIPz7FDn1YXLks1Ok67Sywa7trCww9Xz8nXEI4cTa/G
QspoDMxm3+4ggWSnqvWIqDLVw6Oh0OQPxIoaBvD8UQX8j0kwks5BJl6uFD59WxAC
KxnZAwhuoZa4yLnlTumf
=21y8
-----END PGP SIGNATURE-----

--Signature=_Tue__25_Jun_2013_12_54_43_+1000_8ahz79qvCquAdSdT--

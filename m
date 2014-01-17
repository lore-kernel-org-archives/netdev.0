From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 17 Jan 2014 12:09:55 +1100
Message-ID: <20140117120955.82375d6dce566d44716ea714@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__17_Jan_2014_12_09_55_+1100_n_7KA1gMMn1B3UDx"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Yuval Mintz <yuvalmin@broadcom.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:34545 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751379AbaAQBKD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 20:10:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Fri__17_Jan_2014_12_09_55_+1100_n_7KA1gMMn1B3UDx
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c between commit
d9aee591b0f0 ("bnx2x: Don't release PCI bars on shutdown") from the net
tree and commit 33d8e6a5f555 ("bnx2x: Add AER support (missing bits)")
from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 0067b975873f,cf17b660b4ee..000000000000
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@@ -12942,26 -13082,27 +13082,28 @@@ static void __bnx2x_remove(struct pci=
_d
  		pci_set_power_state(pdev, PCI_D3hot);
  	}
 =20
+ 	bnx2x_disable_pcie_error_reporting(bp);
+=20
 -	if (bp->regview)
 -		iounmap(bp->regview);
 +	if (remove_netdev) {
 +		if (bp->regview)
 +			iounmap(bp->regview);
 =20
 -	/* for vf doorbells are part of the regview and were unmapped along with
 -	 * it. FW is only loaded by PF.
 -	 */
 -	if (IS_PF(bp)) {
 -		if (bp->doorbells)
 -			iounmap(bp->doorbells);
 +		/* For vfs, doorbells are part of the regview and were unmapped
 +		 * along with it. FW is only loaded by PF.
 +		 */
 +		if (IS_PF(bp)) {
 +			if (bp->doorbells)
 +				iounmap(bp->doorbells);
 =20
 -		bnx2x_release_firmware(bp);
 -	}
 -	bnx2x_free_mem_bp(bp);
 +			bnx2x_release_firmware(bp);
 +		}
 +		bnx2x_free_mem_bp(bp);
 =20
 -	if (remove_netdev)
  		free_netdev(dev);
 =20
 -	if (atomic_read(&pdev->enable_cnt) =3D=3D 1)
 -		pci_release_regions(pdev);
 +		if (atomic_read(&pdev->enable_cnt) =3D=3D 1)
 +			pci_release_regions(pdev);
 +	}
 =20
  	pci_disable_device(pdev);
  }

--Signature=_Fri__17_Jan_2014_12_09_55_+1100_n_7KA1gMMn1B3UDx
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJS2ILnAAoJEMDTa8Ir7ZwVV7gQAJE5el0/xvRocH4z9l4qK7Tr
4GWCoUoc7X1f1D4eFBE5ClBqayMPlNXO5HCkepM48T7gC7/6aNV947wtkxDiNdo5
Zg07s4moJ3my+sUI1+M2EPlVQpY6OZGLIFI/sgDv8LECCbLnxsC/gCtCe5za1iWa
7dKYpIBo0u6+jmRsiYHWpLWZmBn/Bu9v8h52ZUkJQsTLtI+KrTJmTDXkf7+OJB3P
MEUYbemiUh9jiSMm93QuadwrwsRNovN3MgF/BXudUCzMTDH+bLtuF0NM/XuBLxId
Ju+aWSme6XlaBTm8WyuImY0XNWcFFjz/rag74BSZz/+dUHmeHDFsY+D6T9ahdzz9
ike3WpQ0ssDNiiKa+MKXiD2BfURcwCDYHtD7iyjrrZeJCstzKcwMMqwAqUJbmxh3
DARpocV+enAyoPZHbkBRi19z9836/4OQrS+6dp8D4RdJ1yH2m12MK3rVHffQdzAU
V2Muqxl4Cd2fY7OCV1y6wAUE/vifwCQDL8o6pSN3Dxnl5x+gd3/ibpewdcdNRpV6
1wJEalAxEMjac9orrUhdXTGRKZ1diZjYNIhJLE9RrfUe97DpwomGXhWCQ4+tP0Jx
rvOQcYhtDPsD40c9Xe4VcnoR25zNws2PvdOg3HWm2ZCH9LyFry4VAiPD3+X9vS0G
pmkwxdBQMu4MbFcdLiBT
=JK6p
-----END PGP SIGNATURE-----

--Signature=_Fri__17_Jan_2014_12_09_55_+1100_n_7KA1gMMn1B3UDx--

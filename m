From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the pci tree
Date: Mon, 10 Dec 2012 12:08:25 +1100
Message-ID: <20121210120825.49096bafd378139e98becb8d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__10_Dec_2012_12_08_25_+1100_Cx6Ts+n/e3Yl1a4D"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Bjorn Helgaas <bhelgaas@google.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Johannes Berg <johannes.berg@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__10_Dec_2012_12_08_25_+1100_Cx6Ts+n/e3Yl1a4D
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/wireless/iwlwifi/pcie/trans.c between commit b9d146e30a2d
("iwlwifi: collapse wrapper for pcie_capability_read_word()") from the
pci tree and commit 7afe3705cd4e ("iwlwifi: continue clean up -
pcie/trans.c") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/iwlwifi/pcie/trans.c
index 1dfa6be,f6c21e7..0000000
--- a/drivers/net/wireless/iwlwifi/pcie/trans.c
+++ b/drivers/net/wireless/iwlwifi/pcie/trans.c
@@@ -670,8 -94,10 +94,8 @@@ static void iwl_pcie_set_pwr_vmain(stru
 =20
  /* PCI registers */
  #define PCI_CFG_RETRY_TIMEOUT	0x041
 -#define PCI_CFG_LINK_CTRL_VAL_L0S_EN	0x01
 -#define PCI_CFG_LINK_CTRL_VAL_L1_EN	0x02
 =20
- static void iwl_apm_config(struct iwl_trans *trans)
+ static void iwl_pcie_apm_config(struct iwl_trans *trans)
  {
  	struct iwl_trans_pcie *trans_pcie =3D IWL_TRANS_GET_PCIE_TRANS(trans);
  	u16 lctl;
@@@ -684,20 -110,19 +108,17 @@@
  	 * If not (unlikely), enable L0S, so there is at least some
  	 *    power savings, even without L1.
  	 */
-=20
  	pcie_capability_read_word(trans_pcie->pci_dev, PCI_EXP_LNKCTL, &lctl);
 -
 -	if ((lctl & PCI_CFG_LINK_CTRL_VAL_L1_EN) =3D=3D
 -				PCI_CFG_LINK_CTRL_VAL_L1_EN) {
 +	if (lctl & PCI_EXP_LNKCTL_ASPM_L1) {
  		/* L1-ASPM enabled; disable(!) L0S */
  		iwl_set_bit(trans, CSR_GIO_REG, CSR_GIO_REG_VAL_L0S_ENABLED);
- 		dev_printk(KERN_INFO, trans->dev,
- 			   "L1 Enabled; Disabling L0S\n");
+ 		dev_info(trans->dev, "L1 Enabled; Disabling L0S\n");
  	} else {
  		/* L1-ASPM disabled; enable(!) L0S */
  		iwl_clear_bit(trans, CSR_GIO_REG, CSR_GIO_REG_VAL_L0S_ENABLED);
- 		dev_printk(KERN_INFO, trans->dev,
- 			   "L1 Disabled; Enabling L0S\n");
+ 		dev_info(trans->dev, "L1 Disabled; Enabling L0S\n");
  	}
 -	trans->pm_support =3D !(lctl & PCI_CFG_LINK_CTRL_VAL_L0S_EN);
 +	trans->pm_support =3D !(lctl & PCI_EXP_LNKCTL_ASPM_L0S);
  }
 =20
  /*

--Signature=_Mon__10_Dec_2012_12_08_25_+1100_Cx6Ts+n/e3Yl1a4D
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQxTYJAAoJEECxmPOUX5FEIeIQAI8AMC5WD9l0yDtjm7PkyqXK
8XG2Bg0kf2qvxpeJXyx3zeBohKUf5+Bn+TUZRuan+MmE1IeuZzFnt6CRgFSOyv5m
jcM0XjwXPy1peRJo+LMbijh0wYXF5b7/CyqR83TEMLGKXWKM3r8Y8dEDUh1tt3zI
1rqthHdxzZUaw/1XF9hdT3elIHcLdb2t/0clKfhbigENimHHQWyHWCP/BizzFRl1
wCLy9wEGoKehwkB6ao3TAB4nL2NF6psArbhX8gH0SF9AMl1pvJkh1SkqByRCurkf
UvNWWbCA450AhyEi+tuFkzYZ77fBRtx74/2oVkBCWiHc8oXSs1XMTToZ1KyjcZcX
rVm5rCW/pE17iLhHDi++wfEfNWZjtlxCHcdKOsyRiNUznmTJdLeQerN3O4Wfytue
JkfIOjab5molZ7eiq4g4A0vFzYlW0Obs2IWk7JLcKDcpIIQ3t4BlUQzLjQ7pxe2i
+hWzEUMkvv+WhL1hwOifzNRk/Blb10JHOmURughMSpHddJerLtv8OVQSuyljO4Ru
kYvrHORdGFq/xC1w4x3UFNvdhadIlK+FS/MM4gjqNL8G+Xu5T1trcNK3kuKiDAJS
zfvD8+UegFQb72O1fkxp+y2O2ZwTd3mx61jUeZCTM94kk7mPCnUB/kfu7M90RF/v
VCSQfAF3y9E3tZDo0srw
=3Nsx
-----END PGP SIGNATURE-----

--Signature=_Mon__10_Dec_2012_12_08_25_+1100_Cx6Ts+n/e3Yl1a4D--

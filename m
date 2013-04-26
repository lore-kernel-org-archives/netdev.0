From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the pci tree
Date: Fri, 26 Apr 2013 13:31:08 +1000
Message-ID: <20130426133108.22cb24082420d26bbae2cbaa@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__26_Apr_2013_13_31_08_+1000_XQiJ9ih8nly/535/"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Bjorn Helgaas <bhelgaas@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__26_Apr_2013_13_31_08_+1000_XQiJ9ih8nly/535/
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
include/linux/pci.h between commit f39d5b72913e ("PCI: Remove "extern"
from function declarations") from the pci tree and commit 5a8eb24292ff
("pci: Add SRIOV helper function to determine if VFs are assigned to
guest") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

(I would have preferred that all these declarations were changed to have
"extern" added to ones that were missing it, but ...)

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc include/linux/pci.h
index e73dfa3,43e45ac..0000000
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@@ -1657,12 -1640,13 +1657,13 @@@ int pci_ext_cfg_avail(void)
  void __iomem *pci_ioremap_bar(struct pci_dev *pdev, int bar);
 =20
  #ifdef CONFIG_PCI_IOV
 -extern int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn);
 -extern void pci_disable_sriov(struct pci_dev *dev);
 -extern irqreturn_t pci_sriov_migration(struct pci_dev *dev);
 -extern int pci_num_vf(struct pci_dev *dev);
 +int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn);
 +void pci_disable_sriov(struct pci_dev *dev);
 +irqreturn_t pci_sriov_migration(struct pci_dev *dev);
 +int pci_num_vf(struct pci_dev *dev);
+ int pci_vfs_assigned(struct pci_dev *dev);
 -extern int pci_sriov_set_totalvfs(struct pci_dev *dev, u16 numvfs);
 -extern int pci_sriov_get_totalvfs(struct pci_dev *dev);
 +int pci_sriov_set_totalvfs(struct pci_dev *dev, u16 numvfs);
 +int pci_sriov_get_totalvfs(struct pci_dev *dev);
  #else
  static inline int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn)
  {

--Signature=_Fri__26_Apr_2013_13_31_08_+1000_XQiJ9ih8nly/535/
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRefT8AAoJEECxmPOUX5FEAosP/3zoVQWxI04AVKuMDDI3m9sw
RFUchNC0yiiWe2AoqFf+eNMJXVG9KCtWRKFhwHEJhEwRAdMImfS/mYzJm4jGJRlX
idjC0j5al65WtWgCSgIbPSCtrM2e+2aJIR0SX58d/FnPvT00faC4mpuzxnh9hmUH
OHlk2MusXb9xtxkLTrOjaSxW5Y4/QxthDXcCvyniK4duReEmI+q2iTCmO29XQoLG
ZV/utl+UeXWjihD/ZEkiCQolj11P5ACYZFGk2iyxk4eRN6dPSf6vbMnQ9lKqBsK8
dWFq2Z6FKvQ/ELJDVu4DB+H21sphYT5GZZOE2yHbFwVgdlzbD1vGK/p1poZ21XtE
fKEs6isvIQQkF/JyDwGxYX6jAsqpwXVLV3zMc5nFUZ1mSH+239IxNlyC1oZCODJF
OB7Tf4In5ReuPnQUHOIlWQuoeB94nB9oBp5+1L30ZcQX2kmL1/GrNjukclqiqmNH
nTBnbOr/3kg0dcds8kjw4tjrgNgNbkiSvw4ZcAkgTm3D2++/b0gEA6FgVZdp6136
aVREpKNTuquXszLfQXf4Q0YUvKNQVR/0PRevaMyCbEDXcDSvwhMf4O3PgqxD54bE
0tRn+H54afdQA3hBzzXdeYBBIOinEPEVCF8Mlnc5pP2Yd+F3+b1rMHwcen60As70
aGuc6gkWtMUIThrMDJd+
=kHMs
-----END PGP SIGNATURE-----

--Signature=_Fri__26_Apr_2013_13_31_08_+1000_XQiJ9ih8nly/535/--

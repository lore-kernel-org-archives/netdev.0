From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] intel: make wired ethernet driver message level consistent
 (rev2)
Date: Sun, 11 Mar 2012 15:12:56 -0700
Message-ID: <20120311151256.55532b2a@nehalam.linuxnetplumber.net>
References: <20120310084921.GA4647@elgon.mountain>
	<20120310160153.1d3e5f19@nehalam.linuxnetplumber.net>
	<1331426337.3022.106.camel@deadeye>
	<20120310164435.70bcd0e5@nehalam.linuxnetplumber.net>
	<1331459836.27038.7.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA256;
 boundary="Sig_/LX9ktIPMou/c0KGqKc/CHfD"; protocol="application/pgp-signature"
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38793 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753893Ab2CKWNB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Mar 2012 18:13:01 -0400
In-Reply-To: <1331459836.27038.7.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/LX9ktIPMou/c0KGqKc/CHfD
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Dan Carpenter noticed that ixgbevf initial default was different than
the rest. But the problem is broader than that, only one Intel driver (ixgb)
was doing it almost right.

The convention for default debug level should be consistent among
Intel drivers and follow established convention.

Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
rev2 - use msg mask for default as expected rather than shift

 drivers/net/ethernet/intel/e1000/e1000_main.c     |    5 +++--
 drivers/net/ethernet/intel/e1000e/netdev.c        |    7 ++++++-
 drivers/net/ethernet/intel/igb/igb_main.c         |    7 ++++++-
 drivers/net/ethernet/intel/igbvf/netdev.c         |    7 ++++++-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c       |    6 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    9 ++++++---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    7 +++++--
 7 files changed, 35 insertions(+), 13 deletions(-)

--- a/drivers/net/ethernet/intel/e1000/e1000_main.c	2012-02-27 08:43:02.348=
936997 -0800
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c	2012-03-11 15:10:04.754=
698066 -0700
@@ -215,7 +215,8 @@ MODULE_DESCRIPTION("Intel(R) PRO/1000 Ne
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
=20
-static int debug =3D NETIF_MSG_DRV | NETIF_MSG_PROBE;
+#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV|NETIF_MSG_PROBE|NETIF_MSG_LINK)
+static int debug =3D -1;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=3Dnone,...,16=3Dall)");
=20
@@ -979,7 +980,7 @@ static int __devinit e1000_probe(struct
 	adapter =3D netdev_priv(netdev);
 	adapter->netdev =3D netdev;
 	adapter->pdev =3D pdev;
-	adapter->msg_enable =3D (1 << debug) - 1;
+	adapter->msg_enable =3D netif_msg_init(debug, DEFAULT_MSG_ENABLE);
 	adapter->bars =3D bars;
 	adapter->need_ioport =3D need_ioport;
=20
--- a/drivers/net/ethernet/intel/e1000e/netdev.c	2012-03-04 21:12:14.059108=
802 -0800
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c	2012-03-11 15:01:15.765998=
170 -0700
@@ -60,6 +60,11 @@
 char e1000e_driver_name[] =3D "e1000e";
 const char e1000e_driver_version[] =3D DRV_VERSION;
=20
+#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV|NETIF_MSG_PROBE|NETIF_MSG_LINK)
+static int debug =3D -1;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Debug level (0=3Dnone,...,16=3Dall)");
+
 static void e1000e_disable_aspm(struct pci_dev *pdev, u16 state);
=20
 static const struct e1000_info *e1000_info_tbl[] =3D {
@@ -6175,7 +6180,7 @@ static int __devinit e1000_probe(struct
 	adapter->hw.adapter =3D adapter;
 	adapter->hw.mac.type =3D ei->mac;
 	adapter->max_hw_frame_size =3D ei->max_hw_frame_size;
-	adapter->msg_enable =3D (1 << NETIF_MSG_DRV | NETIF_MSG_PROBE) - 1;
+	adapter->msg_enable =3D netif_msg_init(debug, DEFAULT_MSG_ENABLE);
=20
 	mmio_start =3D pci_resource_start(pdev, 0);
 	mmio_len =3D pci_resource_len(pdev, 0);
--- a/drivers/net/ethernet/intel/igb/igb_main.c	2012-02-13 09:23:53.6224470=
01 -0800
+++ b/drivers/net/ethernet/intel/igb/igb_main.c	2012-03-11 15:01:50.9503057=
07 -0700
@@ -238,6 +238,11 @@ MODULE_DESCRIPTION("Intel(R) Gigabit Eth
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
=20
+#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV|NETIF_MSG_PROBE|NETIF_MSG_LINK)
+static int debug =3D -1;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Debug level (0=3Dnone,...,16=3Dall)");
+
 struct igb_reg_info {
 	u32 ofs;
 	char *name;
@@ -1882,7 +1887,7 @@ static int __devinit igb_probe(struct pc
 	adapter->pdev =3D pdev;
 	hw =3D &adapter->hw;
 	hw->back =3D adapter;
-	adapter->msg_enable =3D NETIF_MSG_DRV | NETIF_MSG_PROBE;
+	adapter->msg_enable =3D netif_msg_init(debug, DEFAULT_MSG_ENABLE);
=20
 	mmio_start =3D pci_resource_start(pdev, 0);
 	mmio_len =3D pci_resource_len(pdev, 0);
--- a/drivers/net/ethernet/intel/igbvf/netdev.c	2012-02-24 10:04:00.1232370=
28 -0800
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c	2012-03-11 15:02:55.2468696=
31 -0700
@@ -55,6 +55,11 @@ static const char igbvf_driver_string[]
 static const char igbvf_copyright[] =3D
 		  "Copyright (c) 2009 - 2012 Intel Corporation.";
=20
+#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV|NETIF_MSG_PROBE|NETIF_MSG_LINK)
+static int debug =3D -1;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Debug level (0=3Dnone,...,16=3Dall)");
+
 static int igbvf_poll(struct napi_struct *napi, int budget);
 static void igbvf_reset(struct igbvf_adapter *);
 static void igbvf_set_interrupt_capability(struct igbvf_adapter *);
@@ -2649,7 +2654,7 @@ static int __devinit igbvf_probe(struct
 	adapter->flags =3D ei->flags;
 	adapter->hw.back =3D adapter;
 	adapter->hw.mac.type =3D ei->mac;
-	adapter->msg_enable =3D (1 << NETIF_MSG_DRV | NETIF_MSG_PROBE) - 1;
+	adapter->msg_enable =3D netif_msg_init(debug, DEFAULT_MSG_ENABLE);
=20
 	/* PCI config space info */
=20
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c	2012-03-04 21:12:14.063=
108911 -0800
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c	2012-03-11 15:09:36.874=
446437 -0700
@@ -136,13 +136,16 @@ module_param(allow_unsupported_sfp, uint
 MODULE_PARM_DESC(allow_unsupported_sfp,
 		 "Allow unsupported and untested SFP+ modules on 82599-based adapters");
=20
+#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV|NETIF_MSG_PROBE|NETIF_MSG_LINK)
+static int debug =3D -1;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Debug level (0=3Dnone,...,16=3Dall)");
+
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
 MODULE_DESCRIPTION("Intel(R) 10 Gigabit PCI Express Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
=20
-#define DEFAULT_DEBUG_LEVEL_SHIFT 3
-
 static void ixgbe_service_event_schedule(struct ixgbe_adapter *adapter)
 {
 	if (!test_bit(__IXGBE_DOWN, &adapter->state) &&
@@ -7638,7 +7641,7 @@ static int __devinit ixgbe_probe(struct
 	adapter->pdev =3D pdev;
 	hw =3D &adapter->hw;
 	hw->back =3D adapter;
-	adapter->msg_enable =3D (1 << DEFAULT_DEBUG_LEVEL_SHIFT) - 1;
+	adapter->msg_enable =3D netif_msg_init(debug, DEFAULT_MSG_ENABLE);
=20
 	hw->hw_addr =3D ioremap(pci_resource_start(pdev, 0),
 			      pci_resource_len(pdev, 0));
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c	2012-02-27 08:43:02=
.356936810 -0800
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c	2012-03-11 15:09:29=
.186377123 -0700
@@ -91,7 +91,10 @@ MODULE_DESCRIPTION("Intel(R) 82599 Virtu
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
=20
-#define DEFAULT_DEBUG_LEVEL_SHIFT 3
+#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV|NETIF_MSG_PROBE|NETIF_MSG_LINK)
+static int debug =3D -1;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Debug level (0=3Dnone,...,16=3Dall)");
=20
 /* forward decls */
 static void ixgbevf_set_itr_msix(struct ixgbevf_q_vector *q_vector);
@@ -3367,7 +3370,7 @@ static int __devinit ixgbevf_probe(struc
 	adapter->pdev =3D pdev;
 	hw =3D &adapter->hw;
 	hw->back =3D adapter;
-	adapter->msg_enable =3D (1 << DEFAULT_DEBUG_LEVEL_SHIFT) - 1;
+	adapter->msg_enable =3D netif_msg_init(debug, DEFAULT_MSG_ENABLE);
=20
 	/*
 	 * call save state here in standalone driver because it relies on
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c	2012-02-13 09:23:53.62644=
7048 -0800
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c	2012-03-11 15:04:00.26344=
2371 -0700
@@ -134,8 +134,8 @@ MODULE_DESCRIPTION("Intel(R) PRO/10GbE N
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
=20
-#define DEFAULT_DEBUG_LEVEL_SHIFT 3
-static int debug =3D DEFAULT_DEBUG_LEVEL_SHIFT;
+#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV|NETIF_MSG_PROBE|NETIF_MSG_LINK)
+static int debug =3D -1;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=3Dnone,...,16=3Dall)");
=20
@@ -442,7 +442,7 @@ ixgb_probe(struct pci_dev *pdev, const s
 	adapter->netdev =3D netdev;
 	adapter->pdev =3D pdev;
 	adapter->hw.back =3D adapter;
-	adapter->msg_enable =3D netif_msg_init(debug, DEFAULT_DEBUG_LEVEL_SHIFT);
+	adapter->msg_enable =3D netif_msg_init(debug, DEFAULT_MSG_ENABLE);
=20
 	adapter->hw.hw_addr =3D pci_ioremap_bar(pdev, BAR_0);
 	if (!adapter->hw.hw_addr) {

--Sig_/LX9ktIPMou/c0KGqKc/CHfD
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPXSNoAAoJEICnf2CVzeR+kmEP/RtqiBNAXT7P5l7g/7/Dl7vm
S61gz/U4MVGrttxsoAQ55xiLMLUbp7t9L31CLqA5aKjlAq+VTWv/vJo5n7HtcvlE
vuK0GNKbRoDVEcNTMweCyyTu6bNr4CueHK/NoC5+BsUSI/tZbw8obyPGXQp9kNKV
dA/nXI168/aE7U/h6rgQFX7fmEcAtzZGICj+t6ND5dl247cOfuKa0FRbO7Ndrpew
TLicd2q+bfI2RfHePIcETHNNBCHUj5cFCt6CNb/qHpj1LN7p+5xQrdsgGy2l/NZ6
YM+d1xqXHtvCxFIFv4GsgICW+M4nYP0AuXC/C5DVMak7m4vm1k9TEcPBovVxtIHw
IidJQP/tITmT5hlsTXKWSNqPYXkRG4tp1Fhfs3oNIaVr3/S4F3TDFuHMZAFDEzIx
4bewU6awwpvB+fqpa468NbBSso4XhICK75D7LKQAc9qDRdR4l+dXx+VgOYhoNymY
FLKf0r5ITImD1wu3mIy6CxwiVtRJEjYlBJzqi+ib1BwEJLIvD1F8ddH8bG8QyBzm
Q9vXfUoSAj7ujHooBpFBWR/SK9MxHSV5JXdKuGeTok/+QIKtzQUg22epSTtbMq2Q
CHwnL+zHdGO+qhNIvGrKKbtbTu4MlaHiDKjSMzOepHCi86g8mDtTf389FBplQ0KZ
KozcGFvRY3mSfnWD8Q9K
=Q+mU
-----END PGP SIGNATURE-----

--Sig_/LX9ktIPMou/c0KGqKc/CHfD--

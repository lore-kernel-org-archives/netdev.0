From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 3/4] e1000/e1000e: Move PCI-Express device IDs over to e1000e
Date: Wed, 31 Oct 2007 15:22:05 -0700
Message-ID: <20071031222205.17411.8456.stgit@localhost.localdomain>
References: <20071031222152.17411.20977.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	john.ronciak@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:29287 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752082AbXJaWZJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 18:25:09 -0400
In-Reply-To: <20071031222152.17411.20977.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

e1000e will from now on support the PCI-Express adapters that
previously were supported by e1000. This support means better
performance and easier debugging from now on for both the old
PCI-X/PCI hardware and PCI-Express adapters.

This patch also moves 3 recently merged device IDs over to e1000e
that are identical to quad-port versions of already existing
dual port versions. With this last bit every former e1000 pci-e
device should work now with e1000e.

Here is a brief list of which gigabit driver to use with which
adapter:

  e1000:
	82540 -> 82547

  e1000e:
	82571 -> 82573
	ich8, ich9       (82562 or 82566)
	es2lan           (80003eslan)

  igb: (not yet merged, only available from e1000.sf.net)
	82575

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   27 ---------------------------
 drivers/net/e1000e/82571.c     |    6 ++++++
 drivers/net/e1000e/hw.h        |    3 +++
 drivers/net/e1000e/netdev.c    |    9 +++------
 4 files changed, 12 insertions(+), 33 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 72deff0..d1b88e4 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -73,14 +73,6 @@ static struct pci_device_id e1000_pci_tbl[] = {
 	INTEL_E1000_ETHERNET_DEVICE(0x1026),
 	INTEL_E1000_ETHERNET_DEVICE(0x1027),
 	INTEL_E1000_ETHERNET_DEVICE(0x1028),
-	INTEL_E1000_ETHERNET_DEVICE(0x1049),
-	INTEL_E1000_ETHERNET_DEVICE(0x104A),
-	INTEL_E1000_ETHERNET_DEVICE(0x104B),
-	INTEL_E1000_ETHERNET_DEVICE(0x104C),
-	INTEL_E1000_ETHERNET_DEVICE(0x104D),
-	INTEL_E1000_ETHERNET_DEVICE(0x105E),
-	INTEL_E1000_ETHERNET_DEVICE(0x105F),
-	INTEL_E1000_ETHERNET_DEVICE(0x1060),
 	INTEL_E1000_ETHERNET_DEVICE(0x1075),
 	INTEL_E1000_ETHERNET_DEVICE(0x1076),
 	INTEL_E1000_ETHERNET_DEVICE(0x1077),
@@ -89,28 +81,9 @@ static struct pci_device_id e1000_pci_tbl[] = {
 	INTEL_E1000_ETHERNET_DEVICE(0x107A),
 	INTEL_E1000_ETHERNET_DEVICE(0x107B),
 	INTEL_E1000_ETHERNET_DEVICE(0x107C),
-	INTEL_E1000_ETHERNET_DEVICE(0x107D),
-	INTEL_E1000_ETHERNET_DEVICE(0x107E),
-	INTEL_E1000_ETHERNET_DEVICE(0x107F),
 	INTEL_E1000_ETHERNET_DEVICE(0x108A),
-	INTEL_E1000_ETHERNET_DEVICE(0x108B),
-	INTEL_E1000_ETHERNET_DEVICE(0x108C),
-	INTEL_E1000_ETHERNET_DEVICE(0x1096),
-	INTEL_E1000_ETHERNET_DEVICE(0x1098),
 	INTEL_E1000_ETHERNET_DEVICE(0x1099),
-	INTEL_E1000_ETHERNET_DEVICE(0x109A),
-	INTEL_E1000_ETHERNET_DEVICE(0x10A4),
-	INTEL_E1000_ETHERNET_DEVICE(0x10A5),
 	INTEL_E1000_ETHERNET_DEVICE(0x10B5),
-	INTEL_E1000_ETHERNET_DEVICE(0x10B9),
-	INTEL_E1000_ETHERNET_DEVICE(0x10BA),
-	INTEL_E1000_ETHERNET_DEVICE(0x10BB),
-	INTEL_E1000_ETHERNET_DEVICE(0x10BC),
-	INTEL_E1000_ETHERNET_DEVICE(0x10C4),
-	INTEL_E1000_ETHERNET_DEVICE(0x10C5),
-	INTEL_E1000_ETHERNET_DEVICE(0x10D5),
-	INTEL_E1000_ETHERNET_DEVICE(0x10D9),
-	INTEL_E1000_ETHERNET_DEVICE(0x10DA),
 	/* required last entry */
 	{0,}
 };
diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 45f5ee2..3beace5 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -194,6 +194,8 @@ static s32 e1000_init_mac_params_82571(struct e1000_adapter *adapter)
 		break;
 	case E1000_DEV_ID_82571EB_SERDES:
 	case E1000_DEV_ID_82572EI_SERDES:
+	case E1000_DEV_ID_82571EB_SERDES_DUAL:
+	case E1000_DEV_ID_82571EB_SERDES_QUAD:
 		hw->media_type = e1000_media_type_internal_serdes;
 		break;
 	default:
@@ -260,6 +262,7 @@ static s32 e1000_get_invariants_82571(struct e1000_adapter *adapter)
 	case E1000_DEV_ID_82571EB_QUAD_COPPER:
 	case E1000_DEV_ID_82571EB_QUAD_FIBER:
 	case E1000_DEV_ID_82571EB_QUAD_COPPER_LP:
+	case E1000_DEV_ID_82571PT_QUAD_COPPER:
 		adapter->flags |= FLAG_IS_QUAD_PORT;
 		/* mark the first port */
 		if (global_quad_port_a == 0)
@@ -285,6 +288,9 @@ static s32 e1000_get_invariants_82571(struct e1000_adapter *adapter)
 		if (adapter->flags & FLAG_IS_QUAD_PORT &&
 		    (!(adapter->flags & FLAG_IS_QUAD_PORT_A)))
 			adapter->flags &= ~FLAG_HAS_WOL;
+		/* Does not support WoL on any port */
+		if (pdev->device == E1000_DEV_ID_82571EB_SERDES_QUAD)
+			adapter->flags &= ~FLAG_HAS_WOL;
 		break;
 
 	case e1000_82573:
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 1bb2052..71f93ce 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -303,8 +303,11 @@ enum e1e_registers {
 #define E1000_DEV_ID_82571EB_FIBER		0x105F
 #define E1000_DEV_ID_82571EB_SERDES		0x1060
 #define E1000_DEV_ID_82571EB_QUAD_COPPER	0x10A4
+#define E1000_DEV_ID_82571PT_QUAD_COPPER	0x10D5
 #define E1000_DEV_ID_82571EB_QUAD_FIBER		0x10A5
 #define E1000_DEV_ID_82571EB_QUAD_COPPER_LP	0x10BC
+#define E1000_DEV_ID_82571EB_SERDES_DUAL	0x10D9
+#define E1000_DEV_ID_82571EB_SERDES_QUAD	0x10DA
 #define E1000_DEV_ID_82572EI_COPPER		0x107D
 #define E1000_DEV_ID_82572EI_FIBER		0x107E
 #define E1000_DEV_ID_82572EI_SERDES		0x107F
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index ec427e2..a271112 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4088,16 +4088,15 @@ static struct pci_error_handlers e1000_err_handler = {
 };
 
 static struct pci_device_id e1000_pci_tbl[] = {
-	/*
-	 * Support for 82571/2/3, es2lan and ich8 will be phased in
-	 * stepwise.
-
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_COPPER), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_FIBER), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_QUAD_COPPER), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_QUAD_COPPER_LP), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_QUAD_FIBER), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_SERDES), board_82571 },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_SERDES_DUAL), board_82571 },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_SERDES_QUAD), board_82571 },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571PT_QUAD_COPPER), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82572EI), board_82572 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82572EI_COPPER), board_82572 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82572EI_FIBER), board_82572 },
@@ -4120,8 +4119,6 @@ static struct pci_device_id e1000_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH8_IGP_C), board_ich8lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH8_IGP_M), board_ich8lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH8_IGP_M_AMT), board_ich8lan },
-	*/
-
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IFE), board_ich9lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IFE_G), board_ich9lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IFE_GT), board_ich9lan },

From: Joe Perches <joe@perches.com>
Subject: [PATCH 12/19] drivers/net: Use PCI_VDEVICE
Date: Wed, 24 Jun 2009 22:13:28 -0700
Message-ID: <f746d5c571120f930fb6bb50d8303766573f927d.1245906152.git.joe@perches.com>
References: <cover.1245906151.git.joe@perches.com>
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Divy Le Ray <divy@chelsio.com>,
	Samuel Ortiz <samuel@sortiz.org>,
	Tim Hockin <thockin@hockin.org>,
	Daniele Venzano <venza@brownhat.org>,
	Jens Osterkamp <jens@de.ibm.com>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	Ion Badulescu <ionut@cs.columbia.edu>,
	Andy Gospodarek <andy@greyhouse.net>,
	Alexander Indenbaum <baum@tehutinetworks.net>,
	Samuel Chessman <chessman@tux.org>,
	Kyle McMartin <kyle@mcmartin.ca>,
	Grant Grundler <grundler@parisc-linux.org>,
	David Dillow <dave@thedillows.org>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:1465 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756243AbZFYFOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 01:14:04 -0400
In-Reply-To: <cover.1245906151.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/3c59x.c               |   90 ++++++++++++++++++------------------
 drivers/net/8139too.c             |   18 ++++----
 drivers/net/amd8111e.c            |    3 +-
 drivers/net/arcnet/com20020-pci.c |    6 +-
 drivers/net/bnx2.c                |   24 +++-------
 drivers/net/bnx2x_main.c          |    9 +---
 drivers/net/cassini.c             |    6 +--
 drivers/net/cxgb3/cxgb3_main.c    |    2 +-
 drivers/net/irda/via-ircc.c       |   10 ++--
 drivers/net/natsemi.c             |    2 +-
 drivers/net/ne2k-pci.c            |   12 +++---
 drivers/net/pci-skeleton.c        |    4 +-
 drivers/net/sis900.c              |    6 +--
 drivers/net/spider_net.c          |    3 +-
 drivers/net/starfire.c            |    2 +-
 drivers/net/sundance.c            |    6 +-
 drivers/net/sungem.c              |   24 +++-------
 drivers/net/tehuti.c              |    6 +-
 drivers/net/tlan.c                |   39 +++++-----------
 drivers/net/tokenring/tmspci.c    |    8 ++--
 drivers/net/tulip/de2104x.c       |    6 +--
 drivers/net/tulip/de4x5.c         |   12 ++---
 drivers/net/tulip/tulip_core.c    |   28 ++++++------
 drivers/net/tulip/uli526x.c       |    4 +-
 drivers/net/tulip/winbond-840.c   |    4 +-
 drivers/net/typhoon.c             |   18 +++-----
 drivers/net/yellowfin.c           |    4 +-
 27 files changed, 153 insertions(+), 203 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index c34aee9..6b8d205 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -373,51 +373,51 @@ static struct vortex_chip_info {
 
 
 static struct pci_device_id vortex_pci_tbl[] = {
-	{ 0x10B7, 0x5900, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C590 },
-	{ 0x10B7, 0x5920, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C592 },
-	{ 0x10B7, 0x5970, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C597 },
-	{ 0x10B7, 0x5950, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C595_1 },
-	{ 0x10B7, 0x5951, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C595_2 },
-
-	{ 0x10B7, 0x5952, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C595_3 },
-	{ 0x10B7, 0x9000, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C900_1 },
-	{ 0x10B7, 0x9001, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C900_2 },
-	{ 0x10B7, 0x9004, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C900_3 },
-	{ 0x10B7, 0x9005, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C900_4 },
-
-	{ 0x10B7, 0x9006, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C900_5 },
-	{ 0x10B7, 0x900A, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C900B_FL },
-	{ 0x10B7, 0x9050, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C905_1 },
-	{ 0x10B7, 0x9051, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C905_2 },
-	{ 0x10B7, 0x9055, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C905B_1 },
-
-	{ 0x10B7, 0x9058, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C905B_2 },
-	{ 0x10B7, 0x905A, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C905B_FX },
-	{ 0x10B7, 0x9200, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C905C },
-	{ 0x10B7, 0x9202, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C9202 },
-	{ 0x10B7, 0x9800, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C980 },
-	{ 0x10B7, 0x9805, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C9805 },
-
-	{ 0x10B7, 0x7646, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3CSOHO100_TX },
-	{ 0x10B7, 0x5055, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C555 },
-	{ 0x10B7, 0x6055, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C556 },
-	{ 0x10B7, 0x6056, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C556B },
-	{ 0x10B7, 0x5b57, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C575 },
-
-	{ 0x10B7, 0x5057, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C575_1 },
-	{ 0x10B7, 0x5157, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3CCFE575 },
-	{ 0x10B7, 0x5257, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3CCFE575CT },
-	{ 0x10B7, 0x6560, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3CCFE656 },
-	{ 0x10B7, 0x6562, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3CCFEM656 },
-
-	{ 0x10B7, 0x6564, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3CCFEM656_1 },
-	{ 0x10B7, 0x4500, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C450 },
-	{ 0x10B7, 0x9201, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C920 },
-	{ 0x10B7, 0x1201, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C982A },
-	{ 0x10B7, 0x1202, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C982B },
-
-	{ 0x10B7, 0x9056, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_905BT4 },
-	{ 0x10B7, 0x9210, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_920B_EMB_WNM },
+	{ PCI_VDEVICE(3COM, 0x5900), CH_3C590 },
+	{ PCI_VDEVICE(3COM, 0x5920), CH_3C592 },
+	{ PCI_VDEVICE(3COM, 0x5970), CH_3C597 },
+	{ PCI_VDEVICE(3COM, 0x5950), CH_3C595_1 },
+	{ PCI_VDEVICE(3COM, 0x5951), CH_3C595_2 },
+
+	{ PCI_VDEVICE(3COM, 0x5952), CH_3C595_3 },
+	{ PCI_VDEVICE(3COM, 0x9000), CH_3C900_1 },
+	{ PCI_VDEVICE(3COM, 0x9001), CH_3C900_2 },
+	{ PCI_VDEVICE(3COM, 0x9004), CH_3C900_3 },
+	{ PCI_VDEVICE(3COM, 0x9005), CH_3C900_4 },
+
+	{ PCI_VDEVICE(3COM, 0x9006), CH_3C900_5 },
+	{ PCI_VDEVICE(3COM, 0x900A), CH_3C900B_FL },
+	{ PCI_VDEVICE(3COM, 0x9050), CH_3C905_1 },
+	{ PCI_VDEVICE(3COM, 0x9051), CH_3C905_2 },
+	{ PCI_VDEVICE(3COM, 0x9055), CH_3C905B_1 },
+
+	{ PCI_VDEVICE(3COM, 0x9058), CH_3C905B_2 },
+	{ PCI_VDEVICE(3COM, 0x905A), CH_3C905B_FX },
+	{ PCI_VDEVICE(3COM, 0x9200), CH_3C905C },
+	{ PCI_VDEVICE(3COM, 0x9202), CH_3C9202 },
+	{ PCI_VDEVICE(3COM, 0x9800), CH_3C980 },
+	{ PCI_VDEVICE(3COM, 0x9805), CH_3C9805 },
+
+	{ PCI_VDEVICE(3COM, 0x7646), CH_3CSOHO100_TX },
+	{ PCI_VDEVICE(3COM, 0x5055), CH_3C555 },
+	{ PCI_VDEVICE(3COM, 0x6055), CH_3C556 },
+	{ PCI_VDEVICE(3COM, 0x6056), CH_3C556B },
+	{ PCI_VDEVICE(3COM, 0x5b57), CH_3C575 },
+
+	{ PCI_VDEVICE(3COM, 0x5057), CH_3C575_1 },
+	{ PCI_VDEVICE(3COM, 0x5157), CH_3CCFE575 },
+	{ PCI_VDEVICE(3COM, 0x5257), CH_3CCFE575CT },
+	{ PCI_VDEVICE(3COM, 0x6560), CH_3CCFE656 },
+	{ PCI_VDEVICE(3COM, 0x6562), CH_3CCFEM656 },
+
+	{ PCI_VDEVICE(3COM, 0x6564), CH_3CCFEM656_1 },
+	{ PCI_VDEVICE(3COM, 0x4500), CH_3C450 },
+	{ PCI_VDEVICE(3COM, 0x9201), CH_3C920 },
+	{ PCI_VDEVICE(3COM, 0x1201), CH_3C982A },
+	{ PCI_VDEVICE(3COM, 0x1202), CH_3C982B },
+
+	{ PCI_VDEVICE(3COM, 0x9056), CH_905BT4 },
+	{ PCI_VDEVICE(3COM, 0x9210), CH_920B_EMB_WNM },
 
 	{0,}						/* 0 terminated list. */
 };
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 8ae72ec..fb4944a 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -232,16 +232,16 @@ static const struct {
 
 
 static struct pci_device_id rtl8139_pci_tbl[] = {
-	{0x10ec, 0x8139, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
-	{0x10ec, 0x8138, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
+	{PCI_VDEVICE(REALTEK, 0x8139), RTL8139 },
+	{PCI_VDEVICE(REALTEK, 0x8138), RTL8139 },
 	{0x1113, 0x1211, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x1500, 0x1360, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x4033, 0x1360, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
-	{0x1186, 0x1300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
-	{0x1186, 0x1340, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
-	{0x13d1, 0xab06, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
-	{0x1259, 0xa117, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
-	{0x1259, 0xa11e, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
+	{PCI_VDEVICE(DLINK, 0x1300), RTL8139 },
+	{PCI_VDEVICE(DLINK, 0x1340), RTL8139 },
+	{PCI_VDEVICE(ABOCOM, 0xab06), RTL8139 },
+	{PCI_VDEVICE(AT, 0xa117), RTL8139 },
+	{PCI_VDEVICE(AT, 0xa11e), RTL8139 },
 	{0x14ea, 0xab06, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x14ea, 0xab07, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x11db, 0x1234, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
@@ -254,10 +254,10 @@ static struct pci_device_id rtl8139_pci_tbl[] = {
 
 #ifdef CONFIG_SH_SECUREEDGE5410
 	/* Bogus 8139 silicon reports 8129 without external PROM :-( */
-	{0x10ec, 0x8129, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
+	{PCI_VDEVICE(REALTEK, 0x8129), RTL8139 },
 #endif
 #ifdef CONFIG_8139TOO_8129
-	{0x10ec, 0x8129, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8129 },
+	{PCI_VDEVICE(REALTEK, 0x8129), RTL8129 },
 #endif
 
 	/* some crazy cards report invalid vendor ids like
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index 19831bd..ede19b8 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -115,8 +115,7 @@ MODULE_PARM_DESC(dynamic_ipg, "Enable or Disable dynamic IPG, 1: Enable, 0: Disa
 
 static struct pci_device_id amd8111e_pci_tbl[] = {
 
-	{ PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD8111E_7462,
-	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
+	{ PCI_VDEVICE(AMD, PCI_DEVICE_ID_AMD8111E_7462), 0UL },
 	{ 0, }
 
 };
diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index dbf4de3..1c65222 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -165,10 +165,10 @@ static struct pci_device_id com20020pci_id_table[] = {
 	{ 0x1571, 0xa204, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
 	{ 0x1571, 0xa205, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
 	{ 0x1571, 0xa206, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
-	{ 0x10B5, 0x9030, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
-	{ 0x10B5, 0x9050, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
+	{ PCI_VDEVICE(PLX, 0x9030), ARC_CAN_10MBIT },
+	{ PCI_VDEVICE(PLX, 0x9050), ARC_CAN_10MBIT },
 	{ 0x14BA, 0x6000, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
-	{ 0x10B5, 0x2200, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
+	{ PCI_VDEVICE(PLX, 0x2200), ARC_CAN_10MBIT },
 	{0,}
 };
 
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index b70cc99..8a208c6 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -124,24 +124,16 @@ static DEFINE_PCI_DEVICE_TABLE(bnx2_pci_tbl) = {
 	  PCI_VENDOR_ID_HP, 0x3101, 0, 0, NC370T },
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_5706,
 	  PCI_VENDOR_ID_HP, 0x3106, 0, 0, NC370I },
-	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_5706,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5706 },
-	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_5708,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5708 },
+	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_5706), BCM5706 },
+	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_5708), BCM5708 },
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_5706S,
 	  PCI_VENDOR_ID_HP, 0x3102, 0, 0, NC370F },
-	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_5706S,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5706S },
-	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_5708S,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5708S },
-	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_5709,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5709 },
-	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_5709S,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5709S },
-	{ PCI_VENDOR_ID_BROADCOM, 0x163b,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5716 },
-	{ PCI_VENDOR_ID_BROADCOM, 0x163c,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5716S },
+	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_5706S), BCM5706S },
+	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_5708S), BCM5708S },
+	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_5709), BCM5709 },
+	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_5709S), BCM5709S },
+	{ PCI_VDEVICE(BROADCOM, 0x163b), BCM5716 },
+	{ PCI_VDEVICE(BROADCOM, 0x163c), BCM5716S },
 	{ 0, }
 };
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index fbf1352..f2cabdc 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -123,12 +123,9 @@ static struct {
 
 
 static const struct pci_device_id bnx2x_pci_tbl[] = {
-	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_57710,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM57710 },
-	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_57711,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM57711 },
-	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_57711E,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM57711E },
+	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57710), BCM57710 },
+	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57711), BCM57711 },
+	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57711E), BCM57711E },
 	{ 0 }
 };
 
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index eb06667..cd60678 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -237,10 +237,8 @@ static u16 link_modes[] __devinitdata = {
 };
 
 static struct pci_device_id cas_pci_tbl[] __devinitdata = {
-	{ PCI_VENDOR_ID_SUN, PCI_DEVICE_ID_SUN_CASSINI,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
-	{ PCI_VENDOR_ID_NS, PCI_DEVICE_ID_NS_SATURN,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
+	{ PCI_VDEVICE(SUN, PCI_DEVICE_ID_SUN_CASSINI), 0UL },
+	{ PCI_VDEVICE(NS, PCI_DEVICE_ID_NS_SATURN), 0UL },
 	{ 0, }
 };
 
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 538dda4..2405b40 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -77,7 +77,7 @@ enum {
 #define EEPROM_MAGIC 0x38E2F10C
 
 #define CH_DEVICE(devid, idx) \
-	{ PCI_VENDOR_ID_CHELSIO, devid, PCI_ANY_ID, PCI_ANY_ID, 0, 0, idx }
+	{ PCI_VDEVICE(CHELSIO, devid), idx }
 
 static const struct pci_device_id cxgb3_pci_tbl[] = {
 	CH_DEVICE(0x20, 0),	/* PE9000 */
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 8647985..ced05d1 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -122,11 +122,11 @@ static void iodelay(int udelay)
 }
 
 static struct pci_device_id via_pci_tbl[] = {
-	{ PCI_VENDOR_ID_VIA, 0x8231, PCI_ANY_ID, PCI_ANY_ID,0,0,0 },
-	{ PCI_VENDOR_ID_VIA, 0x3109, PCI_ANY_ID, PCI_ANY_ID,0,0,1 },
-	{ PCI_VENDOR_ID_VIA, 0x3074, PCI_ANY_ID, PCI_ANY_ID,0,0,2 },
-	{ PCI_VENDOR_ID_VIA, 0x3147, PCI_ANY_ID, PCI_ANY_ID,0,0,3 },
-	{ PCI_VENDOR_ID_VIA, 0x3177, PCI_ANY_ID, PCI_ANY_ID,0,0,4 },
+	{ PCI_VDEVICE(VIA, 0x8231), 0 },
+	{ PCI_VDEVICE(VIA, 0x3109), 1 },
+	{ PCI_VDEVICE(VIA, 0x3074), 2 },
+	{ PCI_VDEVICE(VIA, 0x3147), 3 },
+	{ PCI_VDEVICE(VIA, 0x3177), 4 },
 	{ 0, }
 };
 
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index c9bfe4e..5ba33bc 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -249,7 +249,7 @@ static struct {
 
 static struct pci_device_id natsemi_pci_tbl[] __devinitdata = {
 	{ PCI_VENDOR_ID_NS, 0x0020, 0x12d9,     0x000c,     0, 0, 0 },
-	{ PCI_VENDOR_ID_NS, 0x0020, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 1 },
+	{ PCI_VDEVICE(NS, 0x0020), 1 },
 	{ }	/* terminate list */
 };
 MODULE_DEVICE_TABLE(pci, natsemi_pci_tbl);
diff --git a/drivers/net/ne2k-pci.c b/drivers/net/ne2k-pci.c
index 3fcebb7..200c302 100644
--- a/drivers/net/ne2k-pci.c
+++ b/drivers/net/ne2k-pci.c
@@ -137,14 +137,14 @@ static struct {
 
 
 static struct pci_device_id ne2k_pci_tbl[] = {
-	{ 0x10ec, 0x8029, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_RealTek_RTL_8029 },
-	{ 0x1050, 0x0940, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_Winbond_89C940 },
-	{ 0x11f6, 0x1401, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_Compex_RL2000 },
-	{ 0x8e2e, 0x3000, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_KTI_ET32P2 },
+	{ PCI_VDEVICE(REALTEK, 0x8029), CH_RealTek_RTL_8029 },
+	{ PCI_VDEVICE(WINBOND2, 0x0940), CH_Winbond_89C940 },
+	{ PCI_VDEVICE(COMPEX, 0x1401), CH_Compex_RL2000 },
+	{ PCI_VDEVICE(KTI, 0x3000), CH_KTI_ET32P2 },
 	{ 0x4a14, 0x5000, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_NetVin_NV5000SC },
-	{ 0x1106, 0x0926, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_Via_86C926 },
+	{ PCI_VDEVICE(VIA, 0x0926), CH_Via_86C926 },
 	{ 0x10bd, 0x0e34, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_SureCom_NE34 },
-	{ 0x1050, 0x5a5a, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_Winbond_W89C940F },
+	{ PCI_VDEVICE(WINBOND2, 0x5a5a), CH_Winbond_W89C940F },
 	{ 0x12c3, 0x0058, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_Holtek_HT80232 },
 	{ 0x12c3, 0x5598, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_Holtek_HT80229 },
 	{ 0x8c4a, 0x1980, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_Winbond_89C940_8c4a },
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index 8c1f698..6e94f83 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -212,8 +212,8 @@ static struct {
 
 
 static struct pci_device_id netdrv_pci_tbl[] = {
-	{0x10ec, 0x8139, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
-	{0x10ec, 0x8138, PCI_ANY_ID, PCI_ANY_ID, 0, 0, NETDRV_CB },
+	{PCI_VDEVICE(REALTEK, 0x8139), RTL8139 },
+	{PCI_VDEVICE(REALTEK, 0x8138), NETDRV_CB },
 	{0x1113, 0x1211, PCI_ANY_ID, PCI_ANY_ID, 0, 0, SMC1211TX },
 /*	{0x1113, 0x1211, PCI_ANY_ID, PCI_ANY_ID, 0, 0, MPX5030 },*/
 	{0x1500, 0x1360, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DELTA8139 },
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index a9a897b..4b4850a 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -106,10 +106,8 @@ static const char * card_names[] = {
 	"SiS 7016 PCI Fast Ethernet"
 };
 static struct pci_device_id sis900_pci_tbl [] = {
-	{PCI_VENDOR_ID_SI, PCI_DEVICE_ID_SI_900,
-	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, SIS_900},
-	{PCI_VENDOR_ID_SI, PCI_DEVICE_ID_SI_7016,
-	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, SIS_7016},
+	{PCI_VDEVICE(SI, PCI_DEVICE_ID_SI_900), SIS_900},
+	{PCI_VDEVICE(SI, PCI_DEVICE_ID_SI_7016), SIS_7016},
 	{0,}
 };
 MODULE_DEVICE_TABLE (pci, sis900_pci_tbl);
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 90e663f..867bb14 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -72,8 +72,7 @@ MODULE_PARM_DESC(tx_descriptors, "number of descriptors used " \
 char spider_net_driver_name[] = "spidernet";
 
 static struct pci_device_id spider_net_pci_tbl[] = {
-	{ PCI_VENDOR_ID_TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_SPIDER_NET,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
+	{ PCI_VDEVICE(TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_SPIDER_NET), 0UL },
 	{ 0, }
 };
 
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 838cce8..4a55f81 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -302,7 +302,7 @@ enum chipset {
 };
 
 static struct pci_device_id starfire_pci_tbl[] = {
-	{ 0x9004, 0x6915, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_6915 },
+	{ PCI_VDEVICE(ADAPTEC, 0x6915), CH_6915 },
 	{ 0, }
 };
 MODULE_DEVICE_TABLE(pci, starfire_pci_tbl);
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 545f81b..15fac0a 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -211,9 +211,9 @@ static const struct pci_device_id sundance_pci_tbl[] = {
 	{ 0x1186, 0x1002, 0x1186, 0x1003, 0, 0, 1 },
 	{ 0x1186, 0x1002, 0x1186, 0x1012, 0, 0, 2 },
 	{ 0x1186, 0x1002, 0x1186, 0x1040, 0, 0, 3 },
-	{ 0x1186, 0x1002, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 4 },
-	{ 0x13F0, 0x0201, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 5 },
-	{ 0x13F0, 0x0200, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 6 },
+	{ PCI_VDEVICE(DLINK, 0x1002), 4 },
+	{ PCI_VDEVICE(SUNDANCE, 0x0201), 5 },
+	{ PCI_VDEVICE(SUNDANCE, 0x0200), 6 },
 	{ }
 };
 MODULE_DEVICE_TABLE(pci, sundance_pci_tbl);
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index d2dfe0a..7033c29 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -107,8 +107,7 @@ MODULE_LICENSE("GPL");
 #define PFX GEM_MODULE_NAME ": "
 
 static struct pci_device_id gem_pci_tbl[] = {
-	{ PCI_VENDOR_ID_SUN, PCI_DEVICE_ID_SUN_GEM,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
+	{ PCI_VDEVICE(SUN, PCI_DEVICE_ID_SUN_GEM), 0UL },
 
 	/* These models only differ from the original GEM in
 	 * that their tx/rx fifos are of a different size and
@@ -117,20 +116,13 @@ static struct pci_device_id gem_pci_tbl[] = {
 	 * Apple's GMAC does support gigabit on machines with
 	 * the BCM54xx PHYs. -BenH
 	 */
-	{ PCI_VENDOR_ID_SUN, PCI_DEVICE_ID_SUN_RIO_GEM,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
-	{ PCI_VENDOR_ID_APPLE, PCI_DEVICE_ID_APPLE_UNI_N_GMAC,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
-	{ PCI_VENDOR_ID_APPLE, PCI_DEVICE_ID_APPLE_UNI_N_GMACP,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
-	{ PCI_VENDOR_ID_APPLE, PCI_DEVICE_ID_APPLE_UNI_N_GMAC2,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
-	{ PCI_VENDOR_ID_APPLE, PCI_DEVICE_ID_APPLE_K2_GMAC,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
-	{ PCI_VENDOR_ID_APPLE, PCI_DEVICE_ID_APPLE_SH_SUNGEM,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
-	{ PCI_VENDOR_ID_APPLE, PCI_DEVICE_ID_APPLE_IPID2_GMAC,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
+	{ PCI_VDEVICE(SUN, PCI_DEVICE_ID_SUN_RIO_GEM), 0UL },
+	{ PCI_VDEVICE(APPLE, PCI_DEVICE_ID_APPLE_UNI_N_GMAC), 0UL },
+	{ PCI_VDEVICE(APPLE, PCI_DEVICE_ID_APPLE_UNI_N_GMACP), 0UL },
+	{ PCI_VDEVICE(APPLE, PCI_DEVICE_ID_APPLE_UNI_N_GMAC2), 0UL },
+	{ PCI_VDEVICE(APPLE, PCI_DEVICE_ID_APPLE_K2_GMAC), 0UL },
+	{ PCI_VDEVICE(APPLE, PCI_DEVICE_ID_APPLE_SH_SUNGEM), 0UL },
+	{ PCI_VDEVICE(APPLE, PCI_DEVICE_ID_APPLE_IPID2_GMAC), 0UL },
 	{0, }
 };
 
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 3c2679c..70dd73a 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -65,9 +65,9 @@
 #include "tehuti.h"
 
 static struct pci_device_id __devinitdata bdx_pci_tbl[] = {
-	{0x1FC9, 0x3009, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x1FC9, 0x3010, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x1FC9, 0x3014, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{PCI_VDEVICE(TEHUTI, 0x3009), 0},
+	{PCI_VDEVICE(TEHUTI, 0x3010), 0},
+	{PCI_VDEVICE(TEHUTI, 0x3014), 0},
 	{0}
 };
 
diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index 384cb5e..133efc4 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -255,32 +255,19 @@ static struct board {
 };
 
 static struct pci_device_id tlan_pci_tbl[] = {
-	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_COMPAQ_NETEL10,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_COMPAQ_NETEL100,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 1 },
-	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_COMPAQ_NETFLEX3I,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 2 },
-	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_COMPAQ_THUNDER,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 3 },
-	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_COMPAQ_NETFLEX3B,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 4 },
-	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_COMPAQ_NETEL100PI,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 5 },
-	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_COMPAQ_NETEL100D,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 6 },
-	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_COMPAQ_NETEL100I,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 7 },
-	{ PCI_VENDOR_ID_OLICOM, PCI_DEVICE_ID_OLICOM_OC2183,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 8 },
-	{ PCI_VENDOR_ID_OLICOM, PCI_DEVICE_ID_OLICOM_OC2325,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 9 },
-	{ PCI_VENDOR_ID_OLICOM, PCI_DEVICE_ID_OLICOM_OC2326,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 10 },
-	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_NETELLIGENT_10_100_WS_5100,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 11 },
-	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_NETELLIGENT_10_T2,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 12 },
+	{ PCI_VDEVICE(COMPAQ, PCI_DEVICE_ID_COMPAQ_NETEL10), 0 },
+	{ PCI_VDEVICE(COMPAQ, PCI_DEVICE_ID_COMPAQ_NETEL100), 1 },
+	{ PCI_VDEVICE(COMPAQ, PCI_DEVICE_ID_COMPAQ_NETFLEX3I), 2 },
+	{ PCI_VDEVICE(COMPAQ, PCI_DEVICE_ID_COMPAQ_THUNDER), 3 },
+	{ PCI_VDEVICE(COMPAQ, PCI_DEVICE_ID_COMPAQ_NETFLEX3B), 4 },
+	{ PCI_VDEVICE(COMPAQ, PCI_DEVICE_ID_COMPAQ_NETEL100PI), 5 },
+	{ PCI_VDEVICE(COMPAQ, PCI_DEVICE_ID_COMPAQ_NETEL100D), 6 },
+	{ PCI_VDEVICE(COMPAQ, PCI_DEVICE_ID_COMPAQ_NETEL100I), 7 },
+	{ PCI_VDEVICE(OLICOM, PCI_DEVICE_ID_OLICOM_OC2183), 8 },
+	{ PCI_VDEVICE(OLICOM, PCI_DEVICE_ID_OLICOM_OC2325), 9 },
+	{ PCI_VDEVICE(OLICOM, PCI_DEVICE_ID_OLICOM_OC2326), 10 },
+	{ PCI_VDEVICE(COMPAQ, PCI_DEVICE_ID_NETELLIGENT_10_100_WS_5100), 11 },
+	{ PCI_VDEVICE(COMPAQ, PCI_DEVICE_ID_NETELLIGENT_10_T2), 12 },
 	{ 0,}
 };
 MODULE_DEVICE_TABLE(pci, tlan_pci_tbl);
diff --git a/drivers/net/tokenring/tmspci.c b/drivers/net/tokenring/tmspci.c
index f92fe86..a0c3c94 100644
--- a/drivers/net/tokenring/tmspci.c
+++ b/drivers/net/tokenring/tmspci.c
@@ -58,10 +58,10 @@ static struct card_info card_info_table[] = {
 };
 
 static struct pci_device_id tmspci_pci_tbl[] = {
-	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_COMPAQ_TOKENRING, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_TR, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 1 },
-	{ PCI_VENDOR_ID_TCONRAD, PCI_DEVICE_ID_TCONRAD_TOKENRING, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 2 },
-	{ PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3C339, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 3 },
+	{ PCI_VDEVICE(COMPAQ, PCI_DEVICE_ID_COMPAQ_TOKENRING), 0 },
+	{ PCI_VDEVICE(SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_TR), 1 },
+	{ PCI_VDEVICE(TCONRAD, PCI_DEVICE_ID_TCONRAD_TOKENRING), 2 },
+	{ PCI_VDEVICE(3COM, PCI_DEVICE_ID_3COM_3C339), 3 },
 	{ }			/* Terminating entry */
 };
 MODULE_DEVICE_TABLE(pci, tmspci_pci_tbl);
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 81f054d..d2536c5 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -338,10 +338,8 @@ static unsigned int de_ok_to_advertise (struct de_private *de, u32 new_media);
 
 
 static struct pci_device_id de_pci_tbl[] = {
-	{ PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_PLUS,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 1 },
+	{ PCI_VDEVICE(DEC, PCI_DEVICE_ID_DEC_TULIP), 0 },
+	{ PCI_VDEVICE(DEC, PCI_DEVICE_ID_DEC_TULIP_PLUS), 1 },
 	{ },
 };
 MODULE_DEVICE_TABLE(pci, de_pci_tbl);
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index eb72d2e..a208844 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -2348,14 +2348,10 @@ static void __devexit de4x5_pci_remove (struct pci_dev *pdev)
 }
 
 static struct pci_device_id de4x5_pci_tbl[] = {
-        { PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP,
-          PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-        { PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_PLUS,
-          PCI_ANY_ID, PCI_ANY_ID, 0, 0, 1 },
-        { PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_FAST,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 2 },
-        { PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_21142,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 3 },
+        { PCI_VDEVICE(DEC, PCI_DEVICE_ID_DEC_TULIP), 0 },
+        { PCI_VDEVICE(DEC, PCI_DEVICE_ID_DEC_TULIP_PLUS), 1 },
+        { PCI_VDEVICE(DEC, PCI_DEVICE_ID_DEC_TULIP_FAST), 2 },
+        { PCI_VDEVICE(DEC, PCI_DEVICE_ID_DEC_21142), 3 },
         { },
 };
 
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index 2abb5d3..8f3616d 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -208,8 +208,8 @@ struct tulip_chip_table tulip_tbl[] = {
 
 
 static struct pci_device_id tulip_pci_tbl[] = {
-	{ 0x1011, 0x0009, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DC21140 },
-	{ 0x1011, 0x0019, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DC21143 },
+	{ PCI_VDEVICE(DEC, 0x0009), DC21140 },
+	{ PCI_VDEVICE(DEC, 0x0019), DC21143 },
 	{ 0x11AD, 0x0002, PCI_ANY_ID, PCI_ANY_ID, 0, 0, LC82C168 },
 	{ 0x10d9, 0x0512, PCI_ANY_ID, PCI_ANY_ID, 0, 0, MX98713 },
 	{ 0x10d9, 0x0531, PCI_ANY_ID, PCI_ANY_ID, 0, 0, MX98715 },
@@ -220,28 +220,28 @@ static struct pci_device_id tulip_pci_tbl[] = {
 	{ 0x1317, 0x0985, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
 	{ 0x1317, 0x1985, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
 	{ 0x1317, 0x9511, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
-	{ 0x13D1, 0xAB02, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
-	{ 0x13D1, 0xAB03, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
-	{ 0x13D1, 0xAB08, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
+	{ PCI_VDEVICE(ABOCOM, 0xAB02), COMET },
+	{ PCI_VDEVICE(ABOCOM, 0xAB03), COMET },
+	{ PCI_VDEVICE(ABOCOM, 0xAB08), COMET },
 	{ 0x104A, 0x0981, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
 	{ 0x104A, 0x2774, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
-	{ 0x1259, 0xa120, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
-	{ 0x11F6, 0x9881, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMPEX9881 },
-	{ 0x8086, 0x0039, PCI_ANY_ID, PCI_ANY_ID, 0, 0, I21145 },
+	{ PCI_VDEVICE(AT, 0xa120), COMET },
+	{ PCI_VDEVICE(COMPEX, 0x9881), COMPEX9881 },
+	{ PCI_VDEVICE(INTEL, 0x0039), I21145 },
 	{ 0x1282, 0x9100, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DM910X },
 	{ 0x1282, 0x9102, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DM910X },
 	{ 0x1113, 0x1216, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
 	{ 0x1113, 0x1217, PCI_ANY_ID, PCI_ANY_ID, 0, 0, MX98715 },
 	{ 0x1113, 0x9511, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
-	{ 0x1186, 0x1541, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
-	{ 0x1186, 0x1561, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
-	{ 0x1186, 0x1591, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
+	{ PCI_VDEVICE(DLINK, 0x1541), COMET },
+	{ PCI_VDEVICE(DLINK, 0x1561), COMET },
+	{ PCI_VDEVICE(DLINK, 0x1591), COMET },
 	{ 0x14f1, 0x1803, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CONEXANT },
 	{ 0x1626, 0x8410, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
-	{ 0x1737, 0xAB09, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
-	{ 0x1737, 0xAB08, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
+	{ PCI_VDEVICE(LINKSYS, 0xAB09), COMET },
+	{ PCI_VDEVICE(LINKSYS, 0xAB08), COMET },
 	{ 0x17B3, 0xAB08, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
-	{ 0x10b7, 0x9300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET }, /* 3Com 3CSOHO100B-TX */
+	{ PCI_VDEVICE(3COM, 0x9300), COMET }, /* 3Com 3CSOHO100B-TX */
 	{ 0x14ea, 0xab08, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET }, /* Planex FNW-3602-TX */
 	{ 0x1414, 0x0002, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
 	{ } /* terminate list */
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index 9277ce8..090a7d0 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -1782,8 +1782,8 @@ static u16 phy_read_1bit(unsigned long ioaddr, u32 chip_id)
 
 
 static struct pci_device_id uli526x_pci_tbl[] = {
-	{ 0x10B9, 0x5261, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_ULI5261_ID },
-	{ 0x10B9, 0x5263, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_ULI5263_ID },
+	{ PCI_VDEVICE(AL, 0x5261), PCI_ULI5261_ID },
+	{ PCI_VDEVICE(AL, 0x5263), PCI_ULI5263_ID },
 	{ 0, }
 };
 MODULE_DEVICE_TABLE(pci, uli526x_pci_tbl);
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 842b1a2..5f86d08 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -220,8 +220,8 @@ enum chip_capability_flags {
 
 static const struct pci_device_id w840_pci_tbl[] = {
 	{ 0x1050, 0x0840, PCI_ANY_ID, 0x8153,     0, 0, 0 },
-	{ 0x1050, 0x0840, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 1 },
-	{ 0x11f6, 0x2011, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 2 },
+	{ PCI_VDEVICE(WINBOND2, 0x0840), 1 },
+	{ PCI_VDEVICE(COMPEX, 0x2011), 2 },
 	{ }
 };
 MODULE_DEVICE_TABLE(pci, w840_pci_tbl);
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index cf25eb4..c0063c5 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -215,12 +215,9 @@ static struct typhoon_card_info typhoon_card_info[] __devinitdata = {
  * bits 12-16 indicate card type: (0) client and (1) server
  */
 static struct pci_device_id typhoon_pci_tbl[] = {
-	{ PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3CR990,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0,TYPHOON_TX },
-	{ PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3CR990_TX_95,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, TYPHOON_TX95 },
-	{ PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3CR990_TX_97,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, TYPHOON_TX97 },
+	{ PCI_VDEVICE(3COM, PCI_DEVICE_ID_3COM_3CR990), TYPHOON_TX },
+	{ PCI_VDEVICE(3COM, PCI_DEVICE_ID_3COM_3CR990_TX_95), TYPHOON_TX95 },
+	{ PCI_VDEVICE(3COM, PCI_DEVICE_ID_3COM_3CR990_TX_97), TYPHOON_TX97 },
 	{ PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3CR990B,
 	  PCI_ANY_ID, 0x1000, 0, 0, TYPHOON_TXM },
 	{ PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3CR990B,
@@ -235,12 +232,9 @@ static struct pci_device_id typhoon_pci_tbl[] = {
 	  PCI_ANY_ID, 0x2101, 0, 0, TYPHOON_FX95SVR },
 	{ PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3CR990_FX,
 	  PCI_ANY_ID, 0x2102, 0, 0, TYPHOON_FX97SVR },
-	{ PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3CR990SVR95,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, TYPHOON_SVR95 },
-	{ PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3CR990SVR97,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, TYPHOON_SVR97 },
-	{ PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3CR990SVR,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, TYPHOON_SVR },
+	{ PCI_VDEVICE(3COM, PCI_DEVICE_ID_3COM_3CR990SVR95), TYPHOON_SVR95 },
+	{ PCI_VDEVICE(3COM, PCI_DEVICE_ID_3COM_3CR990SVR97), TYPHOON_SVR97 },
+	{ PCI_VDEVICE(3COM, PCI_DEVICE_ID_3COM_3CR990SVR), TYPHOON_SVR },
 	{ 0, }
 };
 MODULE_DEVICE_TABLE(pci, typhoon_pci_tbl);
diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index 3c7a505..97129a7 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -238,8 +238,8 @@ static const struct pci_id_info pci_id_tbl[] = {
 };
 
 static const struct pci_device_id yellowfin_pci_tbl[] = {
-	{ 0x1000, 0x0702, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ 0x1000, 0x0701, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 1 },
+	{ PCI_VDEVICE(NCR, 0x0702), 0 },
+	{ PCI_VDEVICE(NCR, 0x0701), 1 },
 	{ }
 };
 MODULE_DEVICE_TABLE (pci, yellowfin_pci_tbl);
-- 
1.6.3.1.10.g659a0.dirty


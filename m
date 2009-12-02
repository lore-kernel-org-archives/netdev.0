From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 5/9] e1000e: enable new 82567V-3 device
Date: Tue, 01 Dec 2009 17:50:31 -0800
Message-ID: <20091202015009.519.97730.stgit@localhost.localdomain>
References: <20091202014931.519.25024.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.westchester.pa.mail.comcast.net ([76.96.59.243]:41991
	"EHLO QMTA13.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752408AbZLBBum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 20:50:42 -0500
In-Reply-To: <20091202014931.519.25024.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

This new PCI device ID is for a new combination of MAC and PHY both of
which already have supporting code in the driver, just not yet in this
combination.  During validation of the device, an intermittent issue was
discovered with waking it from a suspended state which can be resolved with
the pre-existing workaround to disable gigabit speed prior to suspending.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/hw.h      |    1 +
 drivers/net/e1000e/ich8lan.c |    1 +
 drivers/net/e1000e/netdev.c  |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index e0addf3..41609d5 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -356,6 +356,7 @@ enum e1e_registers {
 #define E1000_DEV_ID_80003ES2LAN_COPPER_SPT	0x10BA
 #define E1000_DEV_ID_80003ES2LAN_SERDES_SPT	0x10BB
 
+#define E1000_DEV_ID_ICH8_82567V_3		0x1501
 #define E1000_DEV_ID_ICH8_IGP_M_AMT		0x1049
 #define E1000_DEV_ID_ICH8_IGP_AMT		0x104A
 #define E1000_DEV_ID_ICH8_IGP_C			0x104B
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 9c38955..fbbc6dd 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -3204,6 +3204,7 @@ void e1000e_disable_gig_wol_ich8lan(struct e1000_hw *hw)
 	u32 phy_ctrl;
 
 	switch (hw->mac.type) {
+	case e1000_ich8lan:
 	case e1000_ich9lan:
 	case e1000_ich10lan:
 	case e1000_pchlan:
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index ab4db52..d57880e 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5342,6 +5342,7 @@ static struct pci_device_id e1000_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH8_IGP_C), board_ich8lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH8_IGP_M), board_ich8lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH8_IGP_M_AMT), board_ich8lan },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH8_82567V_3), board_ich8lan },
 
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IFE), board_ich9lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IFE_G), board_ich9lan },


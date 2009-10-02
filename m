From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/2] ixgbe: add support for 82599 Combined Backplane
Date: Fri, 02 Oct 2009 11:58:04 -0700
Message-ID: <20091002185803.8771.46655.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:49923
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753143AbZJBS7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 14:59:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch will add support for the 82599 Dual port Backplane
device (0x10f8).  This device has the ability to link in serial (KR) and
parallel (KX4/KX) modes, depending on what the switch capabilities are in
the blade chassis.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c |    1 +
 drivers/net/ixgbe/ixgbe_main.c  |    2 ++
 drivers/net/ixgbe/ixgbe_type.h  |    1 +
 3 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 2ec58dc..bb87c43 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -330,6 +330,7 @@ static enum ixgbe_media_type ixgbe_get_media_type_82599(struct ixgbe_hw *hw)
 
 	switch (hw->device_id) {
 	case IXGBE_DEV_ID_82599_KX4:
+	case IXGBE_DEV_ID_82599_COMBO_BACKPLANE:
 	case IXGBE_DEV_ID_82599_XAUI_LOM:
 		/* Default device ID is mezzanine card KX/KX4 */
 		media_type = ixgbe_media_type_backplane;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 1cbc6a3..dc4afa5 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -99,6 +99,8 @@ static struct pci_device_id ixgbe_pci_tbl[] = {
 	 board_82599 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_CX4),
 	 board_82599 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_COMBO_BACKPLANE),
+	 board_82599 },
 
 	/* required last entry */
 	{0, }
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 7c93e92..a71f712 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -52,6 +52,7 @@
 #define IXGBE_DEV_ID_82599_CX4           0x10F9
 #define IXGBE_DEV_ID_82599_SFP           0x10FB
 #define IXGBE_DEV_ID_82599_XAUI_LOM      0x10FC
+#define IXGBE_DEV_ID_82599_COMBO_BACKPLANE 0x10F8
 
 /* General Registers */
 #define IXGBE_CTRL      0x00000


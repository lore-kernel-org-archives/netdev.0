From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 4/8] igb: support wol on second port
Date: Fri, 13 Mar 2009 23:41:17 -0700
Message-ID: <20090314064117.4052.33684.stgit@lost.foo-projects.org>
References: <20090314064020.4052.46249.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:44435 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751583AbZCNGlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 02:41:37 -0400
In-Reply-To: <20090314064020.4052.46249.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

We need to support wol on the second port for situations such as when the
lan ports are on the motherboard itself.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_defines.h |    1 +
 drivers/net/igb/igb_main.c      |    5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index 62e378b..ad2d319 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -512,6 +512,7 @@
 #define NVM_ID_LED_SETTINGS        0x0004
 /* For SERDES output amplitude adjustment. */
 #define NVM_INIT_CONTROL2_REG      0x000F
+#define NVM_INIT_CONTROL3_PORT_B   0x0014
 #define NVM_INIT_CONTROL3_PORT_A   0x0024
 #define NVM_ALT_MAC_ADDR_PTR       0x0037
 #define NVM_CHECKSUM_REG           0x003F
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index d83d30e..4e2cb82 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1329,9 +1329,10 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	 * enable the ACPI Magic Packet filter
 	 */
 
-	if (hw->bus.func == 0 ||
-	    hw->device_id == E1000_DEV_ID_82575EB_COPPER)
+	if (hw->bus.func == 0)
 		hw->nvm.ops.read(hw, NVM_INIT_CONTROL3_PORT_A, 1, &eeprom_data);
+	else if (hw->bus.func == 1)
+		hw->nvm.ops.read(hw, NVM_INIT_CONTROL3_PORT_B, 1, &eeprom_data);
 
 	if (eeprom_data & eeprom_apme_mask)
 		adapter->eeprom_wol |= E1000_WUFC_MAG;


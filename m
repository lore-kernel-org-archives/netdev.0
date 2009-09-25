From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 12/13] e1000: fix namespacecheck warnings
Date: Fri, 25 Sep 2009 15:20:33 -0700
Message-ID: <20090925222033.26715.64977.stgit@localhost.localdomain>
References: <20090925221613.26715.66796.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:54327
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753032AbZIYWUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 18:20:52 -0400
In-Reply-To: <20090925221613.26715.66796.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

a couple of functions needed to be removed/declared static

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_hw.c   |    2 +-
 drivers/net/e1000/e1000_main.c |   14 --------------
 2 files changed, 1 insertions(+), 15 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 50114cd..8d7d87f 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -2190,7 +2190,7 @@ static s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
  * Checks for link up on the hardware.  If link is not up and we have
  * a signal, then we need to force link up.
  */
-s32 e1000_check_for_serdes_link_generic(struct e1000_hw *hw)
+static s32 e1000_check_for_serdes_link_generic(struct e1000_hw *hw)
 {
 	u32 rxcw;
 	u32 ctrl;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 8302e18..bcd192c 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -4349,20 +4349,6 @@ void e1000_pcix_set_mmrbc(struct e1000_hw *hw, int mmrbc)
 	pcix_set_mmrbc(adapter->pdev, mmrbc);
 }
 
-s32 e1000_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value)
-{
-    struct e1000_adapter *adapter = hw->back;
-    u16 cap_offset;
-
-    cap_offset = pci_find_capability(adapter->pdev, PCI_CAP_ID_EXP);
-    if (!cap_offset)
-        return -E1000_ERR_CONFIG;
-
-    pci_read_config_word(adapter->pdev, cap_offset + reg, value);
-
-    return E1000_SUCCESS;
-}
-
 void e1000_io_write(struct e1000_hw *hw, unsigned long port, u32 value)
 {
 	outl(value, port);


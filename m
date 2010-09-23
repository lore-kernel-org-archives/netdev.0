From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/6] e1000e: 82579 SMBus address and LEDs incorrect
	after device reset
Date: Wed, 22 Sep 2010 20:15:33 -0700
Message-ID: <20100923031532.10976.41477.stgit@localhost.localdomain>
References: <20100923031432.10976.81909.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:34262
	"EHLO qmta10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751893Ab0IWDPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 23:15:53 -0400
In-Reply-To: <20100923031432.10976.81909.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Since the hardware is prevented from performing automatic PHY configuration
(the driver does it instead), the OEM_WRITE_ENABLE bit in the EXTCNF_CTRL
register will not get cleared preventing the SMBus address and the LED
configuration to be written to the PHY registers.  On 82579, do not check
the OEM_WRITE_ENABLE bit.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 822de48..fc8c3ce 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -990,9 +990,9 @@ static s32 e1000_sw_lcd_config_ich8lan(struct e1000_hw *hw)
 	cnf_base_addr = data & E1000_EXTCNF_CTRL_EXT_CNF_POINTER_MASK;
 	cnf_base_addr >>= E1000_EXTCNF_CTRL_EXT_CNF_POINTER_SHIFT;
 
-	if (!(data & E1000_EXTCNF_CTRL_OEM_WRITE_ENABLE) &&
-	    ((hw->mac.type == e1000_pchlan) ||
-	     (hw->mac.type == e1000_pch2lan))) {
+	if ((!(data & E1000_EXTCNF_CTRL_OEM_WRITE_ENABLE) &&
+	    (hw->mac.type == e1000_pchlan)) ||
+	     (hw->mac.type == e1000_pch2lan)) {
 		/*
 		 * HW configures the SMBus address and LEDs when the
 		 * OEM and LCD Write Enable bits are set in the NVM.


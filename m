From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH] e1000: Remove unused function e1000_mta_set.
Date: Tue, 25 Aug 2009 07:43:17 -0700
Message-ID: <20090825144250.15297.79619.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Dave Graham <david.graham@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:42020 "EHLO
	QMTA08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755215AbZHYOnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 10:43:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Graham, David <david.graham@intel.com>

Remove function e1000_mta_set, as it is no longer called

Signed-off-by: Dave Graham <david.graham@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_hw.c |   46 ------------------------------------------
 1 files changed, 0 insertions(+), 46 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 1e5ae11..cda6b39 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -5759,52 +5759,6 @@ u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
 }
 
 /******************************************************************************
- * Sets the bit in the multicast table corresponding to the hash value.
- *
- * hw - Struct containing variables accessed by shared code
- * hash_value - Multicast address hash value
- *****************************************************************************/
-void e1000_mta_set(struct e1000_hw *hw, u32 hash_value)
-{
-    u32 hash_bit, hash_reg;
-    u32 mta;
-    u32 temp;
-
-    /* The MTA is a register array of 128 32-bit registers.
-     * It is treated like an array of 4096 bits.  We want to set
-     * bit BitArray[hash_value]. So we figure out what register
-     * the bit is in, read it, OR in the new bit, then write
-     * back the new value.  The register is determined by the
-     * upper 7 bits of the hash value and the bit within that
-     * register are determined by the lower 5 bits of the value.
-     */
-    hash_reg = (hash_value >> 5) & 0x7F;
-    if (hw->mac_type == e1000_ich8lan)
-        hash_reg &= 0x1F;
-
-    hash_bit = hash_value & 0x1F;
-
-    mta = E1000_READ_REG_ARRAY(hw, MTA, hash_reg);
-
-    mta |= (1 << hash_bit);
-
-    /* If we are on an 82544 and we are trying to write an odd offset
-     * in the MTA, save off the previous entry before writing and
-     * restore the old value after writing.
-     */
-    if ((hw->mac_type == e1000_82544) && ((hash_reg & 0x1) == 1)) {
-        temp = E1000_READ_REG_ARRAY(hw, MTA, (hash_reg - 1));
-        E1000_WRITE_REG_ARRAY(hw, MTA, hash_reg, mta);
-        E1000_WRITE_FLUSH();
-        E1000_WRITE_REG_ARRAY(hw, MTA, (hash_reg - 1), temp);
-        E1000_WRITE_FLUSH();
-    } else {
-        E1000_WRITE_REG_ARRAY(hw, MTA, hash_reg, mta);
-        E1000_WRITE_FLUSH();
-    }
-}
-
-/******************************************************************************
  * Puts an ethernet address into a receive address register.
  *
  * hw - Struct containing variables accessed by shared code


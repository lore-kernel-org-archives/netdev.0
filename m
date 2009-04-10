From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 1/3] igb: fix unused external references introduced with
	sr-iov changes
Date: Fri, 10 Apr 2009 01:49:02 -0700
Message-ID: <20090410084901.14739.20428.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:47111
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S939008AbZDJRRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2009 13:17:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

There were several unused external references added with the sr-iov
enablement changes.  This patch changes all those references to static
local references.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_mac.c |    2 +-
 drivers/net/igb/e1000_mac.h |    1 -
 drivers/net/igb/e1000_mbx.c |   17 ++---------------
 drivers/net/igb/e1000_mbx.h |    2 --
 4 files changed, 3 insertions(+), 19 deletions(-)

diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index f4c315b..472f3f1 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -111,7 +111,7 @@ void igb_clear_vfta(struct e1000_hw *hw)
  *  Writes value at the given offset in the register array which stores
  *  the VLAN filter table.
  **/
-void igb_write_vfta(struct e1000_hw *hw, u32 offset, u32 value)
+static void igb_write_vfta(struct e1000_hw *hw, u32 offset, u32 value)
 {
 	array_wr32(E1000_VFTA, offset, value);
 	wrfl();
diff --git a/drivers/net/igb/e1000_mac.h b/drivers/net/igb/e1000_mac.h
index a34de52..1d690b4 100644
--- a/drivers/net/igb/e1000_mac.h
+++ b/drivers/net/igb/e1000_mac.h
@@ -66,7 +66,6 @@ void igb_rar_set(struct e1000_hw *hw, u8 *addr, u32 index);
 s32  igb_check_alt_mac_addr(struct e1000_hw *hw);
 void igb_reset_adaptive(struct e1000_hw *hw);
 void igb_update_adaptive(struct e1000_hw *hw);
-void igb_write_vfta(struct e1000_hw *hw, u32 offset, u32 value);
 
 bool igb_enable_mng_pass_thru(struct e1000_hw *hw);
 
diff --git a/drivers/net/igb/e1000_mbx.c b/drivers/net/igb/e1000_mbx.c
index fe71c7d..840782f 100644
--- a/drivers/net/igb/e1000_mbx.c
+++ b/drivers/net/igb/e1000_mbx.c
@@ -188,7 +188,7 @@ out:
  *  returns SUCCESS if it successfully received a message notification and
  *  copied it into the receive buffer.
  **/
-s32 igb_read_posted_mbx(struct e1000_hw *hw, u32 *msg, u16 size, u16 mbx_id)
+static s32 igb_read_posted_mbx(struct e1000_hw *hw, u32 *msg, u16 size, u16 mbx_id)
 {
 	struct e1000_mbx_info *mbx = &hw->mbx;
 	s32 ret_val = -E1000_ERR_MBX;
@@ -214,7 +214,7 @@ out:
  *  returns SUCCESS if it successfully copied message into the buffer and
  *  received an ack to that message within delay * timeout period
  **/
-s32 igb_write_posted_mbx(struct e1000_hw *hw, u32 *msg, u16 size, u16 mbx_id)
+static s32 igb_write_posted_mbx(struct e1000_hw *hw, u32 *msg, u16 size, u16 mbx_id)
 {
 	struct e1000_mbx_info *mbx = &hw->mbx;
 	s32 ret_val = 0;
@@ -232,19 +232,6 @@ out:
 	return ret_val;
 }
 
-/**
- *  e1000_init_mbx_ops_generic - Initialize NVM function pointers
- *  @hw: pointer to the HW structure
- *
- *  Setups up the function pointers to no-op functions
- **/
-void e1000_init_mbx_ops_generic(struct e1000_hw *hw)
-{
-	struct e1000_mbx_info *mbx = &hw->mbx;
-	mbx->ops.read_posted = igb_read_posted_mbx;
-	mbx->ops.write_posted = igb_write_posted_mbx;
-}
-
 static s32 igb_check_for_bit_pf(struct e1000_hw *hw, u32 mask)
 {
 	u32 mbvficr = rd32(E1000_MBVFICR);
diff --git a/drivers/net/igb/e1000_mbx.h b/drivers/net/igb/e1000_mbx.h
index 6ec9890..ebc02ea 100644
--- a/drivers/net/igb/e1000_mbx.h
+++ b/drivers/net/igb/e1000_mbx.h
@@ -67,8 +67,6 @@
 
 s32 igb_read_mbx(struct e1000_hw *, u32 *, u16, u16);
 s32 igb_write_mbx(struct e1000_hw *, u32 *, u16, u16);
-s32 igb_read_posted_mbx(struct e1000_hw *, u32 *, u16, u16);
-s32 igb_write_posted_mbx(struct e1000_hw *, u32 *, u16, u16);
 s32 igb_check_for_msg(struct e1000_hw *, u16);
 s32 igb_check_for_ack(struct e1000_hw *, u16);
 s32 igb_check_for_rst(struct e1000_hw *, u16);


From: David Miller <davem@davemloft.net>
Subject: [PATCH]: ixgbe: Fix some compiler warnings.
Date: Sun, 01 Mar 2009 20:33:51 -0800 (PST)
Message-ID: <20090301.203351.249644255.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60924
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753821AbZCBEeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 23:34:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[ Commited to net-next-2.6 ]

'pap' is never used in ixgbe_dcb_hw_config_82599()
and 'eec' in ixgbe_acquire_eeptom() is only used when
status == 0 but GCC has some trouble seeing that.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ixgbe/ixgbe_common.c    |    2 +-
 drivers/net/ixgbe/ixgbe_dcb_82599.c |    2 --
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 26ee8a0..245db0e 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -661,7 +661,7 @@ static s32 ixgbe_poll_eeprom_eerd_done(struct ixgbe_hw *hw)
 static s32 ixgbe_acquire_eeprom(struct ixgbe_hw *hw)
 {
 	s32 status = 0;
-	u32 eec;
+	u32 eec = 0;
 	u32 i;
 
 	if (ixgbe_acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM) != 0)
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ixgbe/ixgbe_dcb_82599.c
index 1467d56..adcbac4 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.c
@@ -457,8 +457,6 @@ s32 ixgbe_dcb_config_82599(struct ixgbe_hw *hw)
 s32 ixgbe_dcb_hw_config_82599(struct ixgbe_hw *hw,
                               struct ixgbe_dcb_config *dcb_config)
 {
-	u32  pap = 0;
-
 	ixgbe_dcb_config_packet_buffers_82599(hw, dcb_config);
 	ixgbe_dcb_config_82599(hw);
 	ixgbe_dcb_config_rx_arbiter_82599(hw, dcb_config);
-- 
1.6.1.2.253.ga34a


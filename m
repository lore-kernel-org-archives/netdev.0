From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: return IXGBE_ERR_RAR_INDEX when out of range
Date: Wed, 02 Jun 2010 15:44:05 -0700
Message-ID: <20100602224405.13236.13183.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Shirley Ma <xma@us.ibm.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:38993 "EHLO
	qmta05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758906Ab0FBWoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 18:44:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on original patch from Shirley Ma <xma@us.ibm.com>
Return IXGBE_ERR_RAR_INDEX when RAR index is out of range, instead of
returning IXGBE_SUCCESS.

CC: Shirley Ma <xma@us.ibm.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Acked-by: Don Skidmore <donald.c.skidmore@intel.com>
---

 drivers/net/ixgbe/ixgbe_common.c |    2 ++
 drivers/net/ixgbe/ixgbe_type.h   |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 1159d91..9595b1b 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1188,6 +1188,7 @@ s32 ixgbe_set_rar_generic(struct ixgbe_hw *hw, u32 index, u8 *addr, u32 vmdq,
 		IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
 	} else {
 		hw_dbg(hw, "RAR index %d is out of range.\n", index);
+		return IXGBE_ERR_RAR_INDEX;
 	}
 
 	return 0;
@@ -1219,6 +1220,7 @@ s32 ixgbe_clear_rar_generic(struct ixgbe_hw *hw, u32 index)
 		IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
 	} else {
 		hw_dbg(hw, "RAR index %d is out of range.\n", index);
+		return IXGBE_ERR_RAR_INDEX;
 	}
 
 	/* clear VMDq pool/queue selection for this RAR */
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 2eb6e15..cdd1998 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2609,6 +2609,7 @@ struct ixgbe_info {
 #define IXGBE_ERR_EEPROM_VERSION                -24
 #define IXGBE_ERR_NO_SPACE                      -25
 #define IXGBE_ERR_OVERTEMP                      -26
+#define IXGBE_ERR_RAR_INDEX                     -27
 #define IXGBE_NOT_IMPLEMENTED                   0x7FFFFFFF
 
 #endif /* _IXGBE_TYPE_H_ */


From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/18] ixgbe: Correct length check for round up
Date: Thu,  7 Apr 2016 20:20:58 -0700
Message-ID: <1460085673-87056-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1460085673-87056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:63152 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754166AbcDHDVS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 23:21:18 -0400
In-Reply-To: <1460085673-87056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

The function ixgbe_host_interface_command actually uses a multiple
of word sized buffer to do its business, but only checks against
the actual length passed in. This means that on read operations it
could be possible to modify locations beyond the length passed in.
Change the check to round up in the same way, just to avoid any
possible hazard.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index dfdb114..a2ca9ef 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -3557,7 +3557,7 @@ s32 ixgbe_host_interface_command(struct ixgbe_hw *hw, u32 *buffer,
 	if (buf_len == 0)
 		return 0;
 
-	if (length < (buf_len + hdr_size)) {
+	if (length < round_up(buf_len, 4) + hdr_size) {
 		hw_dbg(hw, "Buffer not large enough for reply message.\n");
 		return IXGBE_ERR_HOST_INTERFACE_COMMAND;
 	}
-- 
2.5.5

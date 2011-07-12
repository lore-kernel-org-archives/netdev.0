From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/4] igb: Fix lack of flush after register write and before delay
Date: Mon, 11 Jul 2011 19:15:11 -0700
Message-ID: <1310436914-4017-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1310436914-4017-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17366 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753988Ab1GLCPR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 22:15:17 -0400
In-Reply-To: <1310436914-4017-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

Register writes followed by a delay are required to have a flush
before the delay in order to commit the values to the register.  Without
the flush, the code following the delay may not function correctly.

Reported-by: Tong Ho <tong.ho@ericsson.com>
Reported-by: Guenter Roeck <guenter.roeck@ericsson.com>
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by:  Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/e1000_82575.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 0f563c8..493e331 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -1735,6 +1735,7 @@ static s32 igb_reset_hw_82580(struct e1000_hw *hw)
 		ctrl |= E1000_CTRL_RST;
 
 	wr32(E1000_CTRL, ctrl);
+	wrfl();
 
 	/* Add delay to insure DEV_RST has time to complete */
 	if (global_device_reset)
-- 
1.7.6


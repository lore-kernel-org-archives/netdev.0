From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 01/24] igb: warn if max_vfs limit is exceeded
Date: Thu,  3 Mar 2011 05:03:26 -0800
Message-ID: <1299157429-15878-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stefan Assmann <sassmann@redhat.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:51571 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758112Ab1CCNET (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 08:04:19 -0500
In-Reply-To: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@redhat.com>

Currently there's no warning printed when max_vfs > 7 is specified with
igb and the maximum of 7 is silently enforced. This patch prints a
warning and informs the user of the actions taken.

Signed-off-by: Stefan Assmann <sassmann@redhat.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/igb_main.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 579dbba..eef380a 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2291,7 +2291,12 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
 	switch (hw->mac.type) {
 	case e1000_82576:
 	case e1000_i350:
-		adapter->vfs_allocated_count = (max_vfs > 7) ? 7 : max_vfs;
+		if (max_vfs > 7) {
+			dev_warn(&pdev->dev,
+				 "Maximum of 7 VFs per PF, using max\n");
+			adapter->vfs_allocated_count = 7;
+		} else
+			adapter->vfs_allocated_count = max_vfs;
 		break;
 	default:
 		break;
-- 
1.7.4


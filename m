From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH 2/2] igb: Don't depend on vlan group for receive size.
Date: Sat, 30 Oct 2010 11:49:51 -0700
Message-ID: <1288464591-31528-2-git-send-email-jesse@nicira.com>
References: <1288464591-31528-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:56805 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755334Ab0J3SuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Oct 2010 14:50:05 -0400
Received: by mail-pz0-f46.google.com with SMTP id 3so263310pzk.19
        for <netdev@vger.kernel.org>; Sat, 30 Oct 2010 11:50:05 -0700 (PDT)
In-Reply-To: <1288464591-31528-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The igb driver currently sets its maximum receive size based on
whether a vlan group is configured.  However, this causes it to
completely drop MTU sized vlan packets when there is no vlan
group, preventing them from showing up in tcpdump, etc.

Signed-off-by: Jesse Gross <jesse@nicira.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
---
 drivers/net/igb/igb_main.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 892d196..5d1c13c 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2830,13 +2830,10 @@ static inline int igb_set_vf_rlpml(struct igb_adapter *adapter, int size,
  **/
 static void igb_rlpml_set(struct igb_adapter *adapter)
 {
-	u32 max_frame_size = adapter->max_frame_size;
+	u32 max_frame_size = adapter->max_frame_size + VLAN_TAG_SIZE;
 	struct e1000_hw *hw = &adapter->hw;
 	u16 pf_id = adapter->vfs_allocated_count;
 
-	if (adapter->vlgrp)
-		max_frame_size += VLAN_TAG_SIZE;
-
 	/* if vfs are enabled we set RLPML to the largest possible request
 	 * size and set the VMOLR RLPML to the size we need */
 	if (pf_id) {
-- 
1.7.1


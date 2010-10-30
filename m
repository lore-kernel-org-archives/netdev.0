From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH 1/2] ixgb: Don't check for vlan group on transmit.
Date: Sat, 30 Oct 2010 11:49:50 -0700
Message-ID: <1288464591-31528-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:38176 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755109Ab0J3SuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Oct 2010 14:50:04 -0400
Received: by pwj3 with SMTP id 3so1060592pwj.19
        for <netdev@vger.kernel.org>; Sat, 30 Oct 2010 11:50:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On transmit, the ixgb driver will only use vlan acceleration if a
vlan group is configured.  This can lead to tags getting dropped
when bridging because the networking core assumes that a driver
that claims vlan acceleration support can do it at all times.  This
change should have been part of commit eab6d18d "vlan: Don't check for
vlan group before vlan_tx_tag_present." but was missed.

Signed-off-by: Jesse Gross <jesse@nicira.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
---
 drivers/net/ixgb/ixgb_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index caa8192..d18194e 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1498,7 +1498,7 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
                      DESC_NEEDED)))
 		return NETDEV_TX_BUSY;
 
-	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		tx_flags |= IXGB_TX_FLAGS_VLAN;
 		vlan_id = vlan_tx_tag_get(skb);
 	}
-- 
1.7.1


From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH 1/2] vlan: Calling vlan_hwaccel_do_receive() is always valid.
Date: Thu, 21 Oct 2010 14:30:42 -0700
Message-ID: <1287696643-9695-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56085 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758336Ab0JUVav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 17:30:51 -0400
Received: by wyf28 with SMTP id 28so74395wyf.19
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 14:30:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is now acceptable to receive vlan tagged packets at any time,
even if CONFIG_VLAN_8021Q is not set.  This means that calling
vlan_hwaccel_do_receive() should not result in BUG() but rather just
behave as if there were no vlan devices configured.

Reported-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 include/linux/if_vlan.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index e607256..cbd3dcd 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -153,7 +153,8 @@ static inline u16 vlan_dev_vlan_id(const struct net_device *dev)
 
 static inline bool vlan_hwaccel_do_receive(struct sk_buff **skb)
 {
-	BUG();
+	if ((*skb)->vlan_tci & VLAN_VID_MASK)
+		(*skb)->pkt_type = PACKET_OTHERHOST;
 	return false;
 }
 #endif
-- 
1.7.1


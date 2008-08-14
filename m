From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/4] bnx2: Use proper CONFIG_VLAN_8021Q to compile the
 VLAN code.
Date: Thu, 14 Aug 2008 15:22:57 -0700
Message-ID: <1218752579-20506-3-git-send-email-mchan@broadcom.com>
References: <1218752579-20506-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2655 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752222AbYHNWTU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2008 18:19:20 -0400
In-Reply-To: <1218752579-20506-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/bnx2.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 0623ceb..a2a010e 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -35,7 +35,7 @@
 #include <linux/time.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
-#ifdef NETIF_F_HW_VLAN_TX
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 #include <linux/if_vlan.h>
 #define BCM_VLAN 1
 #endif
@@ -5963,10 +5963,12 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		vlan_tag_flags |= TX_BD_FLAGS_TCP_UDP_CKSUM;
 	}
 
+#ifdef BCM_VLAN
 	if (bp->vlgrp && vlan_tx_tag_present(skb)) {
 		vlan_tag_flags |=
 			(TX_BD_FLAGS_VLAN_TAG | (vlan_tx_tag_get(skb) << 16));
 	}
+#endif
 	if ((mss = skb_shinfo(skb)->gso_size)) {
 		u32 tcp_opt_len, ip_tcp_len;
 		struct iphdr *iph;
-- 
1.5.6.GIT



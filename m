From: sthemmin@exchange.microsoft.com
Subject: [PATCH 12/14] hv_netvsc: make variable local
Date: Tue, 23 Aug 2016 12:17:55 -0700
Message-ID: <1471979877-17802-12-git-send-email-sthemmin@exchange.microsoft.com>
References: <1471979877-17802-1-git-send-email-sthemmin@exchange.microsoft.com>
Reply-To: sthemmin@microsoft.com
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net ([208.109.80.59]:45782
        "EHLO p3plsmtps2ded02.prod.phx3.secureserver.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754482AbcHWSJL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 14:09:11 -0400
In-Reply-To: <1471979877-17802-1-git-send-email-sthemmin@exchange.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <sthemmin@microsoft.com>

The variable m_ret is only used in one basic block.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 471c476..2a9ccc4 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -956,7 +956,7 @@ int netvsc_send(struct hv_device *device,
 		struct sk_buff *skb)
 {
 	struct netvsc_device *net_device;
-	int ret = 0, m_ret = 0;
+	int ret = 0;
 	struct vmbus_channel *out_channel;
 	u16 q_idx = packet->q_idx;
 	u32 pktlen = packet->total_data_buflen, msd_len = 0;
@@ -1045,8 +1045,8 @@ int netvsc_send(struct hv_device *device,
 	}
 
 	if (msd_send) {
-		m_ret = netvsc_send_pkt(device, msd_send, net_device,
-					NULL, msd_skb);
+		int m_ret = netvsc_send_pkt(device, msd_send, net_device,
+					    NULL, msd_skb);
 
 		if (m_ret != 0) {
 			netvsc_free_send_slot(net_device,
-- 
2.9.3

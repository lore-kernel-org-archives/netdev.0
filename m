From: sthemmin@exchange.microsoft.com
Subject: [PATCH 1/7] hv_netvsc: use consume_skb
Date: Thu, 22 Sep 2016 16:56:29 -0700
Message-ID: <1474588595-16054-2-git-send-email-sthemmin@exchange.microsoft.com>
References: <1474588595-16054-1-git-send-email-sthemmin@exchange.microsoft.com>
Reply-To: sthemmin@microsoft.com
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net ([208.109.80.59]:36100
        "EHLO p3plsmtps2ded02.prod.phx3.secureserver.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757850AbcIVWGH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Sep 2016 18:06:07 -0400
In-Reply-To: <1474588595-16054-1-git-send-email-sthemmin@exchange.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <sthemmin@microsoft.com>

Packets that are transmitted in normal path should use consume_skb
instead of kfree_skb. This allows for better tracing of packet drops.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index ff05b9b..720b5fa 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -635,7 +635,7 @@ static void netvsc_send_tx_complete(struct netvsc_device *net_device,
 		q_idx = nvsc_packet->q_idx;
 		channel = incoming_channel;
 
-		dev_kfree_skb_any(skb);
+		dev_consume_skb_any(skb);
 	}
 
 	num_outstanding_sends =
@@ -944,7 +944,7 @@ int netvsc_send(struct hv_device *device,
 		}
 
 		if (msdp->skb)
-			dev_kfree_skb_any(msdp->skb);
+			dev_consume_skb_any(msdp->skb);
 
 		if (xmit_more && !packet->cp_partial) {
 			msdp->skb = skb;
-- 
1.7.4.1

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 1/2] vxlan: do not set SKB_GSO_UDP
Date: Sun, 28 Apr 2013 21:16:01 +0300
Message-ID: <1367172962-17369-2-git-send-email-dmitry@broadcom.com>
References: <1367172962-17369-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, dmitry@broadcom.com
To: eilong@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4709 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755633Ab3D1SQY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Apr 2013 14:16:24 -0400
In-Reply-To: <1367172962-17369-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since SKB_GSO_* flags are set by appropriate gso_segment callback
in TCP/UDP layer.

CC: Pravin B Shelar <pshelar@nicira.com> 
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/vxlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index a7fd9a0..b92c6a0 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -913,7 +913,7 @@ static int handle_offloads(struct sk_buff *skb)
 		if (unlikely(err))
 			return err;
 
-		skb_shinfo(skb)->gso_type |= (SKB_GSO_UDP_TUNNEL | SKB_GSO_UDP);
+		skb_shinfo(skb)->gso_type |= SKB_GSO_UDP_TUNNEL;
 	} else if (skb->ip_summed != CHECKSUM_PARTIAL)
 		skb->ip_summed = CHECKSUM_NONE;
 
-- 
1.8.1.4

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next 5/5] staging: wilc1000: use reset to set mac header
Date: Fri,  2 Dec 2016 09:51:07 +0800
Message-ID: <1480643467-4420-6-git-send-email-zhangshengju@cmss.chinamobile.com>
References: <1480643467-4420-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:34076 "EHLO
        cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755946AbcLBBvT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 20:51:19 -0500
In-Reply-To: <1480643467-4420-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since offset is zero, it's not necessary to use set function. Reset
function is straightforward, and will remove the unnecessary add
operation in set function.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/staging/wilc1000/linux_mon.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/wilc1000/linux_mon.c b/drivers/staging/wilc1000/linux_mon.c
index 242f82f..f328d75 100644
--- a/drivers/staging/wilc1000/linux_mon.c
+++ b/drivers/staging/wilc1000/linux_mon.c
@@ -111,7 +111,7 @@ void WILC_WFI_monitor_rx(u8 *buff, u32 size)
 	}
 
 	skb->dev = wilc_wfi_mon;
-	skb_set_mac_header(skb, 0);
+	skb_reset_mac_header(skb);
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb->pkt_type = PACKET_OTHERHOST;
 	skb->protocol = htons(ETH_P_802_2);
@@ -215,7 +215,7 @@ static netdev_tx_t WILC_WFI_mon_xmit(struct sk_buff *skb,
 		cb_hdr->tx_flags = 0x0004;
 
 		skb2->dev = wilc_wfi_mon;
-		skb_set_mac_header(skb2, 0);
+		skb_reset_mac_header(skb2);
 		skb2->ip_summed = CHECKSUM_UNNECESSARY;
 		skb2->pkt_type = PACKET_OTHERHOST;
 		skb2->protocol = htons(ETH_P_802_2);
-- 
1.8.3.1

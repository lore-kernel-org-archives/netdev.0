From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next v2 2/4] mac80211_hwsim: use reset to set mac header
Date: Thu,  3 Mar 2016 01:16:55 +0000
Message-ID: <1456967817-7632-3-git-send-email-zhangshengju@cmss.chinamobile.com>
References: <1456967817-7632-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, kvalo@codeaurora.org,
	johannes@sipsolutions.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:3375 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbcCCBP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 20:15:58 -0500
In-Reply-To: <1456967817-7632-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since offset is zero, it's not necessary to use set function. Reset
function is straightforward, and will remove the unnecessary add
operation in set function.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/wireless/mac80211_hwsim.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index a28414c..7b570bf 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -844,7 +844,7 @@ static void mac80211_hwsim_monitor_rx(struct ieee80211_hw *hw,
 	hdr->rt_chbitmask = cpu_to_le16(flags);
 
 	skb->dev = hwsim_mon;
-	skb_set_mac_header(skb, 0);
+	skb_reset_mac_header(skb);
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb->pkt_type = PACKET_OTHERHOST;
 	skb->protocol = htons(ETH_P_802_2);
@@ -887,7 +887,7 @@ static void mac80211_hwsim_monitor_ack(struct ieee80211_channel *chan,
 	memcpy(hdr11->addr1, addr, ETH_ALEN);
 
 	skb->dev = hwsim_mon;
-	skb_set_mac_header(skb, 0);
+	skb_reset_mac_header(skb);
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb->pkt_type = PACKET_OTHERHOST;
 	skb->protocol = htons(ETH_P_802_2);
-- 
1.8.3.1

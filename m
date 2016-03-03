From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next v2 4/4] wireless: use reset to set mac header
Date: Thu,  3 Mar 2016 01:16:57 +0000
Message-ID: <1456967817-7632-5-git-send-email-zhangshengju@cmss.chinamobile.com>
References: <1456967817-7632-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, kvalo@codeaurora.org,
	johannes@sipsolutions.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:5359 "EHLO
	cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbcCCBQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 20:16:41 -0500
In-Reply-To: <1456967817-7632-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since offset is zero, it's not necessary to use set function. Reset
function is straightforward, and will remove the unnecessary add
operation in set function.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 net/wireless/util.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/wireless/util.c b/net/wireless/util.c
index 9277042..7d26eac 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -636,7 +636,7 @@ int ieee80211_data_from_8023(struct sk_buff *skb, const u8 *addr,
 	/* Update skb pointers to various headers since this modified frame
 	 * is going to go through Linux networking code that may potentially
 	 * need things like pointer to IP header. */
-	skb_set_mac_header(skb, 0);
+	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, nh_pos);
 	skb_set_transport_header(skb, h_pos);
 
-- 
1.8.3.1

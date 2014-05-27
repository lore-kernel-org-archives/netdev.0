From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 2/2] macvlan: slight optimization for macvlan_handle_frame
Date: Tue, 27 May 2014 18:53:16 +0800
Message-ID: <1401187996-10252-3-git-send-email-dingtianhong@huawei.com>
References: <1401187996-10252-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <kaber@trash.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:5255 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbaE0Kxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 06:53:52 -0400
In-Reply-To: <1401187996-10252-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add unlikely() micro to the unlikely conditions in the macvlan_handle_frame
for slight optimization.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/macvlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index c9ada17..88694d5 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -314,7 +314,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 	}
 	len = skb->len + ETH_HLEN;
 	skb = skb_share_check(skb, GFP_ATOMIC);
-	if (!skb)
+	if (unlikely(!skb))
 		goto out;
 
 	skb->dev = vlan->dev;
-- 
1.8.0

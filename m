From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 22/54] uli526x: Call dev_kfree/consume_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:05:08 -0700
Message-ID: <1395727540-12148-22-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:34674 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324AbaCYGLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:38 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_kfree_skb_any in uli562x_start_xmit
that can be called in hard irq and other contexts, when the packet is
dropped.

Replace dev_kfree_skb with dev_consume_skb_any in uli562x_start_xmit
that can be called in hard irq and other contexts, when the packet is
transmitted.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/dec/tulip/uli526x.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index aa4ee385091f..aa801a6af7b9 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -607,7 +607,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_buff *skb,
 	/* Too large packet check */
 	if (skb->len > MAX_PACKET_SIZE) {
 		netdev_err(dev, "big packet = %d\n", (u16)skb->len);
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 
@@ -648,7 +648,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_buff *skb,
 	uw32(DCR7, db->cr7_data);
 
 	/* free this SKB */
-	dev_kfree_skb(skb);
+	dev_consume_skb_any(skb);
 
 	return NETDEV_TX_OK;
 }
-- 
1.7.10.4

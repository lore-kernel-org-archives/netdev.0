From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 25/54] ucc_geth: Call dev_consume_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:05:11 -0700
Message-ID: <1395727540-12148-25-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58436 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411AbaCYGL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:28 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_consume_skb_any in ucc_geth_tx that can
be called in hard irq and other contexts, when processing the
tx completion event.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/freescale/ucc_geth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 72291a8904a9..c8299c31b21f 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3261,7 +3261,7 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 
 		dev->stats.tx_packets++;
 
-		dev_kfree_skb(skb);
+		dev_consume_skb_any(skb);
 
 		ugeth->tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]] = NULL;
 		ugeth->skb_dirtytx[txQ] =
-- 
1.7.10.4

From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 01/10] 8139cp: Call dev_kfree_skby_any instead of kfree_skb.
Date: Tue, 11 Mar 2014 14:14:58 -0700
Message-ID: <87lhwgbfot.fsf_-_@xmission.com>
References: <87a9cxf7mp.fsf_-_@xmission.com>
	<20140311.124907.1180556684992271103.davem@davemloft.net>
	<87wqg0cy9d.fsf@xmission.com>
	<20140311.160931.1395978386605601765.davem@davemloft.net>
	<87r468bfqj.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:39532 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752919AbaCKVPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 17:15:08 -0400
In-Reply-To: <87r468bfqj.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Tue, 11 Mar 2014 14:13:56 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Replace kfree_skb with dev_kfree_skb_any in cp_start_xmit
as it can be called in both hard irq and other contexts.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/realtek/8139cp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 737c1a881f78..a3c1daa7ad5c 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -899,7 +899,7 @@ out_unlock:
 
 	return NETDEV_TX_OK;
 out_dma_error:
-	kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 	cp->dev->stats.tx_dropped++;
 	goto out_unlock;
 }
-- 
1.7.5.4

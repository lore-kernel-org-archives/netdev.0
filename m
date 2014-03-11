From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 02/10] 8139too: Call dev_kfree_skby_any instead of dev_kfree_skb.
Date: Tue, 11 Mar 2014 14:15:36 -0700
Message-ID: <87fvmobfnr.fsf_-_@xmission.com>
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
Received: from out01.mta.xmission.com ([166.70.13.231]:39917 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752919AbaCKVPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 17:15:45 -0400
In-Reply-To: <87r468bfqj.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Tue, 11 Mar 2014 14:13:56 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Replace dev_kfree_skb with dev_kfree_skb_any in functions that can
be called in hard irq and other contexts.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/realtek/8139too.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index da5972eefdd2..8cb2f357026e 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -1717,9 +1717,9 @@ static netdev_tx_t rtl8139_start_xmit (struct sk_buff *skb,
 		if (len < ETH_ZLEN)
 			memset(tp->tx_buf[entry], 0, ETH_ZLEN);
 		skb_copy_and_csum_dev(skb, tp->tx_buf[entry]);
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 	} else {
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		dev->stats.tx_dropped++;
 		return NETDEV_TX_OK;
 	}
-- 
1.7.5.4

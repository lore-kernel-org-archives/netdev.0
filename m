From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 07/10] ixgb: Call dev_kfree_skby_any instead of dev_kfree_skb.
Date: Tue, 11 Mar 2014 14:18:42 -0700
Message-ID: <87ob1ca0y5.fsf_-_@xmission.com>
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
Received: from out01.mta.xmission.com ([166.70.13.231]:41167 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752696AbaCKVSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 17:18:49 -0400
In-Reply-To: <87r468bfqj.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Tue, 11 Mar 2014 14:13:56 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Replace dev_kfree_skb with dev_kfree_skb_any in functions that can
be called in hard irq and other contexts.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/intel/ixgb/ixgb_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index 57e390cbe6d0..f42c201f727f 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -1521,12 +1521,12 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	int tso;
 
 	if (test_bit(__IXGB_DOWN, &adapter->flags)) {
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 
 	if (skb->len <= 0) {
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 
@@ -1543,7 +1543,7 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	tso = ixgb_tso(adapter, skb);
 	if (tso < 0) {
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 
-- 
1.7.5.4

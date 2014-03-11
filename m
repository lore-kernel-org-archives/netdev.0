From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 08/11] ixgb: Call dev_kfree_skby_any instead of dev_kfree_skb.
Date: Mon, 10 Mar 2014 20:22:38 -0700
Message-ID: <87y50ho1vl.fsf_-_@xmission.com>
References: <874n3fow2i.fsf@xmission.com>
	<20140304.160825.893718566461536483.davem@davemloft.net>
	<871ty9qvaf.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:37471 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753503AbaCKDWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 23:22:44 -0400
In-Reply-To: <871ty9qvaf.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Mon, 10 Mar 2014 20:16:40 -0700")
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

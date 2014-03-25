From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 52/54] staging/octeon-ethernet: Call dev_kfree/consume_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:05:38 -0700
Message-ID: <1395727540-12148-52-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:59078 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235AbaCYGLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:35 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_kfree_skb_any in cvm_oct_xmit_pow which
can be called in hard irq and other contexts, on the code paths that
drop packets.

Replace dev_kfree_skb with dev_consume_skb_any in cvm_oct_xmit_pow which
can be called in hard irq and other contexts, on the code path where
the packet is transmitted successfully.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/staging/octeon/ethernet-tx.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/octeon/ethernet-tx.c b/drivers/staging/octeon/ethernet-tx.c
index 47541e1608f3..ebb3ebc7176b 100644
--- a/drivers/staging/octeon/ethernet-tx.c
+++ b/drivers/staging/octeon/ethernet-tx.c
@@ -554,7 +554,7 @@ int cvm_oct_xmit_pow(struct sk_buff *skb, struct net_device *dev)
 		printk_ratelimited("%s: Failed to allocate a work queue entry\n",
 				   dev->name);
 		priv->stats.tx_dropped++;
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return 0;
 	}
 
@@ -565,7 +565,7 @@ int cvm_oct_xmit_pow(struct sk_buff *skb, struct net_device *dev)
 				   dev->name);
 		cvmx_fpa_free(work, CVMX_FPA_WQE_POOL, DONT_WRITEBACK(1));
 		priv->stats.tx_dropped++;
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return 0;
 	}
 
@@ -682,7 +682,7 @@ int cvm_oct_xmit_pow(struct sk_buff *skb, struct net_device *dev)
 			     work->grp);
 	priv->stats.tx_packets++;
 	priv->stats.tx_bytes += skb->len;
-	dev_kfree_skb(skb);
+	dev_consume_skb_any(skb);
 	return 0;
 }
 
-- 
1.7.10.4

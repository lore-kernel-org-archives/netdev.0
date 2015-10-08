From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH 4/9] net/can: can_dropped_invalid_skb can be boolean
Date: Thu,  8 Oct 2015 21:28:57 +0800
Message-ID: <1444310942-4428-5-git-send-email-bywxiaobai@163.com>
References: <1444310942-4428-1-git-send-email-bywxiaobai@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, tgraf@suug.ch, herbert@gondor.apana.org.au,
	johannes.berg@intel.com, daniel@iogearbox.net,
	gerrit@erg.abdn.ac.uk, socketcan@hartkopp.net, mkl@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444310942-4428-1-git-send-email-bywxiaobai@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes can_dropped_invalid_skb return bool due to this
particular function only using either one or zero as its return
value.

No functional change.

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 include/linux/can/dev.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/can/dev.h b/include/linux/can/dev.h
index c3a9c8f..c92d6ea 100644
--- a/include/linux/can/dev.h
+++ b/include/linux/can/dev.h
@@ -77,7 +77,7 @@ struct can_priv {
 #define get_canfd_dlc(i)	(min_t(__u8, (i), CANFD_MAX_DLC))
 
 /* Drop a given socketbuffer if it does not contain a valid CAN frame. */
-static inline int can_dropped_invalid_skb(struct net_device *dev,
+static inline bool can_dropped_invalid_skb(struct net_device *dev,
 					  struct sk_buff *skb)
 {
 	const struct canfd_frame *cfd = (struct canfd_frame *)skb->data;
@@ -93,12 +93,12 @@ static inline int can_dropped_invalid_skb(struct net_device *dev,
 	} else
 		goto inval_skb;
 
-	return 0;
+	return false;
 
 inval_skb:
 	kfree_skb(skb);
 	dev->stats.tx_dropped++;
-	return 1;
+	return true;
 }
 
 static inline bool can_is_canfd_skb(const struct sk_buff *skb)
-- 
1.9.1

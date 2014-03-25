From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 47/54] via-velocity: Call dev_kfree_skb_any instead of kfree_skb.
Date: Mon, 24 Mar 2014 23:05:33 -0700
Message-ID: <1395727540-12148-47-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:59110 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395AbaCYGLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:39 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_kfree_skb_any in velocity_xmit that can
be called in hard irq and other contexts.  Packets are freed and
dropped in velocity_xmit when they are too fragmented and can
not be linearized.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/via/via-velocity.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index ad61d26a44f3..de08e86db209 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -2565,7 +2565,7 @@ static netdev_tx_t velocity_xmit(struct sk_buff *skb,
 	/* The hardware can handle at most 7 memory segments, so merge
 	 * the skb if there are more */
 	if (skb_shinfo(skb)->nr_frags > 6 && __skb_linearize(skb)) {
-		kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 
-- 
1.7.10.4

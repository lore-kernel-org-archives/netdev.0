From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 37/54] sc92031: Call dev_consume_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:05:23 -0700
Message-ID: <1395727540-12148-37-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:34647 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265AbaCYGLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:36 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_consume_skb_any in sc92031_start_xmit
that can be called in hard irq and other contexts.

Using dev_consume_skb_any preserves the current semantics (as
dev_kfree_skb is just consume_skb) and since packet drops
are rare is usually accurate.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/silan/sc92031.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/silan/sc92031.c b/drivers/net/ethernet/silan/sc92031.c
index 5eb933c97bba..7daa7d433099 100644
--- a/drivers/net/ethernet/silan/sc92031.c
+++ b/drivers/net/ethernet/silan/sc92031.c
@@ -987,7 +987,7 @@ out_unlock:
 	spin_unlock(&priv->lock);
 
 out:
-	dev_kfree_skb(skb);
+	dev_consume_skb_any(skb);
 
 	return NETDEV_TX_OK;
 }
-- 
1.7.10.4

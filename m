From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: [PATCH] net_tx_action: Call trace_consume_skb() instead of trace_kfree_skb()
Date: Tue, 11 Sep 2012 18:28:18 -0500
Message-ID: <1347406098-22071-1-git-send-email-sbohrer@rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: sanagi.koki@jp.fujitsu.com, davem@davemloft.net,
	eric.dumazet@gmail.com, Shawn Bohrer <sbohrer@rgmadvisors.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:53350 "EHLO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759302Ab2IKX2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 19:28:32 -0400
Received: by obbuo13 with SMTP id uo13so1692933obb.19
        for <netdev@vger.kernel.org>; Tue, 11 Sep 2012 16:28:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call trace_consume_skb() instead of trace_kfree_skb() as skbs are
removed from the completion_queue during transmit.  This avoids false
positives from dropwatch/drop_monitor making them more useful.

Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
---

In my case I seem to hit this tracepoint for every packet I transmit so
these appear to be false positives to me.  Perhaps there are cases where
you could hit this and it is a real packet drop?

 net/core/dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8398836..00774ce 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3015,7 +3015,7 @@ static void net_tx_action(struct softirq_action *h)
 			clist = clist->next;
 
 			WARN_ON(atomic_read(&skb->users));
-			trace_kfree_skb(skb, net_tx_action);
+			trace_consume_skb(skb);
 			__kfree_skb(skb);
 		}
 	}
-- 
1.7.7.6


-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.

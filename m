From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Subject: [PATCH] cxgb4: fix kfree(skb)
Date: Tue, 22 Jun 2010 07:05:51 +0000
Message-ID: <20100622070551.GA10062@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dm@chelsio.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:34680 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754096Ab0FVHFz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jun 2010 03:05:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use kfree_skb for skb pointers
Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
drivers/net/cxgb4/l2t.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4/l2t.c b/drivers/net/cxgb4/l2t.c
index 5b990d2..e8f0f55 100644
--- a/drivers/net/cxgb4/l2t.c
+++ b/drivers/net/cxgb4/l2t.c
@@ -314,7 +314,7 @@ static void t4_l2e_free(struct l2t_entry *e)
 			struct sk_buff *skb = e->arpq_head;
 
 			e->arpq_head = skb->next;
-			kfree(skb);
+			kfree_skb(skb);
 		}
 		e->arpq_tail = NULL;
 	}

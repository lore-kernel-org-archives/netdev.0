From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] farsync: fix support for over 30 cards
Date: Tue, 9 Oct 2012 10:20:48 +0300
Message-ID: <20121009072047.GB19159@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Kevin Curtis <kevin.curtis@farsite.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:36198 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981Ab2JIHVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 03:21:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We're trying to fill a 64 bit bitmap but only the lower 30 shifts work
because the shift wraps around.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Static checker stuff.  No one actually has over 30 of these cards...  :P

diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index 1a62318..b627132 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -597,7 +597,7 @@ fst_q_work_item(u64 * queue, int card_index)
 	 * bottom half for the card.  Note the limitation of 64 cards.
 	 * That ought to be enough
 	 */
-	mask = 1 << card_index;
+	mask = (u64)1 << card_index;
 	*queue |= mask;
 	spin_unlock_irqrestore(&fst_work_q_lock, flags);
 }

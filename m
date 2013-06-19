From: Dean Jenkins <Dean_Jenkins@mentor.com>
Subject: [PATCH 4/5] SLIP: Add error message for xleft non-zero
Date: Wed, 19 Jun 2013 16:34:30 +0100
Message-ID: <1371656071-27754-5-git-send-email-Dean_Jenkins@mentor.com>
References: <1371656071-27754-1-git-send-email-Dean_Jenkins@mentor.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpc6-farn7-2-0-cust119.6-2.cable.virginmedia.com ([81.110.26.120]:37739
	"EHLO localhost.localdomain" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756954Ab3FSPlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 11:41:31 -0400
In-Reply-To: <1371656071-27754-1-git-send-email-Dean_Jenkins@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a printk to show when xleft is non-zero in sl_encaps.

The idea is to see whether a previous SLIP frame failed to be
fully transmitted.

Signed-off-by: Dean Jenkins <Dean_Jenkins@mentor.com>
---
 drivers/net/slip/slip.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/slip/slip.c b/drivers/net/slip/slip.c
index f7303e0..e2eff84 100644
--- a/drivers/net/slip/slip.c
+++ b/drivers/net/slip/slip.c
@@ -395,6 +395,10 @@ static void sl_encaps(struct slip *sl, unsigned char *icp, int len)
 #endif
 		count = slip_esc(p, sl->xbuff, len);
 
+	if (sl->xleft)
+		printk(KERN_ERR "%s: ERROR: xleft is non-zero %d\n",
+		       __func__, sl->xleft);
+
 	/* ensure xleft set by the previous SLIP frame is zero for this frame
 	 * otherwise slip_write_wakeup() can cause a recursive loop.
 	 */
-- 
1.8.1.5

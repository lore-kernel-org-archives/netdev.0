From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH 1/2] tc35815: Fix return value of tc35815_do_interrupt when NAPI enabled
Date: Mon, 26 Oct 2009 22:46:21 +0900
Message-ID: <1256564782-2781-1-git-send-email-anemo@mba.ocn.ne.jp>
Cc: David Miller <davem@davemloft.net>,
	Ralf Roesch <ralf.roesch@rw-gmbh.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.28.14.163]:58164 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751920AbZJZNqV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2009 09:46:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return received count correctly even if tx completed at the same time.
Currently NAPI is disabled for this driver so this patch does not fix
any real problem.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/tc35815.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index d1298e5..3d38479 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1592,7 +1592,12 @@ static int tc35815_do_interrupt(struct net_device *dev, u32 status)
 		lp->lstats.tx_ints++;
 		tc35815_txdone(dev);
 		netif_wake_queue(dev);
+#ifdef TC35815_NAPI
+		if (ret < 0)
+			ret = 0;
+#else
 		ret = 0;
+#endif
 	}
 	return ret;
 }
-- 
1.5.6.5


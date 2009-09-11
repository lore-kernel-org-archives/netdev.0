From: mcarlson <mcarlson@broadcom.com>
Subject: [PATCH] tg3: Fix return ring size breakage
Date: Fri, 11 Sep 2009 16:23:19 -0700
Message-ID: <1252711336.12629@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3100 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753114AbZIKXWS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 19:22:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit f6eb9b1fc1411d22c073f5264e5630a541d0f7df, "tg3: Add 5717 asic
rev" changed how the rx return ring size operations are done.  It
effectively inverts the sense of the previous test, but it failed to
also invert the resulting sizes.  This patch corrects that error.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 7cf8000..f09bc5d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -112,7 +112,7 @@
  */
 #define TG3_RX_RCB_RING_SIZE(tp)	\
 	(((tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) && \
-	  !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) ? 512 : 1024)
+	  !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) ? 1024 : 512)
 
 #define TG3_TX_RING_SIZE		512
 #define TG3_DEF_TX_RING_PENDING		(TG3_TX_RING_SIZE - 1)
-- 
1.6.3.3



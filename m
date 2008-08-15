From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 2/7] tg3: Refine APE status check
Date: Fri, 15 Aug 2008 13:57:43 -0700
Message-ID: <1218834764.6475@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2540 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752035AbYHOU1o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2008 16:27:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently, more status bits have been added to the APE status register.
This patch refines the status register check so that the driver can
send more events than it would have otherwise.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

---
 drivers/net/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index e3fd74b..13640f1 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5495,7 +5495,7 @@ static void tg3_ape_send_event(struct tg3 *tp, u32 event)
 		return;
 
 	apedata = tg3_ape_read32(tp, TG3_APE_FW_STATUS);
-	if (apedata != APE_FW_STATUS_READY)
+	if (!(apedata & APE_FW_STATUS_READY))
 		return;
 
 	/* Wait for up to 1 millisecond for APE to service previous event. */
-- 
1.5.6.4




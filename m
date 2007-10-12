From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH] tg3: Fix APE induced regression
Date: Thu, 11 Oct 2007 18:43:50 -0700
Message-ID: <1192153431.4878.219.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2855 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753640AbXJLBoH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2007 21:44:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a bug caused by the recent APE support added for 5761
devices.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d2b30fb..e978a79 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6966,9 +6966,10 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		break;
 	};
 
-	/* Write our heartbeat update interval to APE. */
-	tg3_ape_write32(tp, TG3_APE_HOST_HEARTBEAT_INT_MS,
-			APE_HOST_HEARTBEAT_INT_DISABLE);
+	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)
+		/* Write our heartbeat update interval to APE. */
+		tg3_ape_write32(tp, TG3_APE_HOST_HEARTBEAT_INT_MS,
+				APE_HOST_HEARTBEAT_INT_DISABLE);
 
 	tg3_write_sig_post_reset(tp, RESET_KIND_INIT);
 



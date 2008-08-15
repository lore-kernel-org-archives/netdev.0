From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 4/7] tg3: Turn off ASF "driver alive" heartbeats for APE
Date: Fri, 15 Aug 2008 13:59:02 -0700
Message-ID: <1218834766.6481@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3928 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751386AbYHOU1d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2008 16:27:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ENABLE_ASF flag is set when DASH is enabled on the NIC, but DASH
does not run on the RX CPU.  Instead it runs on the APE.
Consequently, the driver does not need to send "driver alive" updates
to the RX CPU when the APE is present.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

---
 drivers/net/tg3.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 0ebf2ff..e952b91 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7862,7 +7862,8 @@ static void tg3_timer(unsigned long __opaque)
 	 * resets.
 	 */
 	if (!--tp->asf_counter) {
-		if (tp->tg3_flags & TG3_FLAG_ENABLE_ASF) {
+		if ((tp->tg3_flags & TG3_FLAG_ENABLE_ASF) &&
+		    !(tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)) {
 			u32 val;
 
 			tg3_wait_for_event_ack(tp);
-- 
1.5.6.4




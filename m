From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH] bridge: Correctly clamp MAX forward_delay when enabling STP
Date: Tue, 15 Oct 2013 14:57:45 -0400
Message-ID: <1381863465-27304-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4214 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754754Ab3JOS5z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Oct 2013 14:57:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit be4f154d5ef0ca147ab6bcd38857a774133f5450
	bridge: Clamp forward_delay when enabling STP
had a typo when attempting to clamp maximum forward delay.

It is possible to set bridge_forward_delay to be higher then
permitted maximum when STP is off.  When turning STP on, the
higher then allowed delay has to be clamed down to max value.

CC: Herbert Xu <herbert@gondor.apana.org.au>
CC: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_stp_if.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 108084a..656a6f3 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -134,7 +134,7 @@ static void br_stp_start(struct net_bridge *br)
 
 	if (br->bridge_forward_delay < BR_MIN_FORWARD_DELAY)
 		__br_set_forward_delay(br, BR_MIN_FORWARD_DELAY);
-	else if (br->bridge_forward_delay < BR_MAX_FORWARD_DELAY)
+	else if (br->bridge_forward_delay > BR_MAX_FORWARD_DELAY)
 		__br_set_forward_delay(br, BR_MAX_FORWARD_DELAY);
 
 	if (r == 0) {
-- 
1.8.3.1

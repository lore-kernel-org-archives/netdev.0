From: Barry Grussling <barry@grussling.com>
Subject: [PATCH 1/1] Allow cascading to work with 6131 chip
Date: Mon, 20 Jun 2011 13:40:33 -0700
Message-ID: <1308602433-31320-2-git-send-email-barry@grussling.com>
References: <1308602433-31320-1-git-send-email-barry@grussling.com>
Cc: buytenh@wantstofly.org, Barry Grussling <barry@grussling.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from duster.selinc.com ([74.117.214.140]:48772 "EHLO
	duster.selinc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754985Ab1FTVOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 17:14:06 -0400
In-Reply-To: <1308602433-31320-1-git-send-email-barry@grussling.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 net/dsa/mv88e6131.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/dsa/mv88e6131.c b/net/dsa/mv88e6131.c
index 45f7411..1a1d1d1 100644
--- a/net/dsa/mv88e6131.c
+++ b/net/dsa/mv88e6131.c
@@ -118,10 +118,14 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 	REG_WRITE(REG_GLOBAL, 0x1a, (dsa_upstream_port(ds) * 0x1100) | 0x00f0);
 
 	/*
-	 * Disable cascade port functionality, and set the switch's
+	 * Disable cascade port functionality unless this device is
+    * used in a cascade configuration, and set the switch's
 	 * DSA device number.
 	 */
-	REG_WRITE(REG_GLOBAL, 0x1c, 0xe000 | (ds->index & 0x1f));
+   if (ds->dst->pd->nr_chips > 1)
+      REG_WRITE(REG_GLOBAL, 0x1c, 0xf000 | (ds->index & 0x1f));
+   else
+      REG_WRITE(REG_GLOBAL, 0x1c, 0xe000 | (ds->index & 0x1f));
 
 	/*
 	 * Send all frames with destination addresses matching
-- 
1.7.0.4


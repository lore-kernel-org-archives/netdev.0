From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH] bridge: Allow forward delay to be cfgd when STP enabled
Date: Thu, 24 Sep 2015 11:20:11 -0700
Message-ID: <1443118811-9400-1-git-send-email-stephen@networkplumber.org>
Cc: Ian Wilson <iwilson@brocade.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35041 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755331AbbIXSUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 14:20:09 -0400
Received: by pacfv12 with SMTP id fv12so81118819pac.2
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 11:20:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Wilson <iwilson@brocade.com>

Allow bridge forward delay to be configured when Spanning Tree is enabled.

Signed-off-by: Ian Wilson <iwilson@brocade.com>
Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/bridge/br_stp.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index ed74ffa..3a7392e 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -576,17 +576,12 @@ void __br_set_forward_delay(struct net_bridge *br, unsigned long t)
 int br_set_forward_delay(struct net_bridge *br, unsigned long val)
 {
 	unsigned long t = clock_t_to_jiffies(val);
-	int err = -ERANGE;
 
-	spin_lock_bh(&br->lock);
-	if (br->stp_enabled != BR_NO_STP &&
-	    (t < BR_MIN_FORWARD_DELAY || t > BR_MAX_FORWARD_DELAY))
-		goto unlock;
+	if (t < BR_MIN_FORWARD_DELAY || t > BR_MAX_FORWARD_DELAY)
+		return -ERANGE;
 
+	spin_lock_bh(&br->lock);
 	__br_set_forward_delay(br, t);
-	err = 0;
-
-unlock:
 	spin_unlock_bh(&br->lock);
-	return err;
+	return 0;
 }
-- 
2.1.4

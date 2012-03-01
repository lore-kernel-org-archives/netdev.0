From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH 1/2] bridge: Adjust min age inc for HZ > 256
Date: Thu, 1 Mar 2012 19:12:18 +0100
Message-ID: <1330625539-10247-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:32892 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755790Ab2CASM1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2012 13:12:27 -0500
Received: from mail1.transmode.se (mail1.transmode.se [192.168.201.18])
	by gw1.transmode.se (Postfix) with ESMTP id ED9052581E1
	for <netdev@vger.kernel.org>; Thu,  1 Mar 2012 19:12:24 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

min age increment needs to round up its min age tick for all
HZ values to guarantee message age is increasing.

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---

The bridge list seems very slow so try netdev instead.

 net/bridge/br_stp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index a04eeb6..9a8aebd 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -17,9 +17,9 @@
 #include "br_private_stp.h"
 
 /* since time values in bpdu are in jiffies and then scaled (1/256)
- * before sending, make sure that is at least one.
+ * before sending, make sure that is at least one STP tick.
  */
-#define MESSAGE_AGE_INCR	((HZ < 256) ? 1 : (HZ/256))
+#define MESSAGE_AGE_INCR	((HZ / 256) + 1)
 
 static const char *const br_port_state_names[] = {
 	[BR_STATE_DISABLED] = "disabled",
-- 
1.7.3.4

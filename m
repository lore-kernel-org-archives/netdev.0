From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] IRDA: Fix global type conflicts in net/irda/irsysctl.c v2
Date: Fri, 16 Sep 2011 12:09:50 -0700
Message-ID: <1316200190-2320-1-git-send-email-andi@firstfloor.org>
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	Andi Kleen <ak@linux.intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:46553 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753832Ab1IPTJy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 15:09:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <ak@linux.intel.com>

The externs here didn't agree with the declarations in qos.c.

Better would be probably to move this into a header, but since it's
common practice to have naked externs with sysctls I left it for now.

v2: add some redundancy
Cc: samuel@sortiz.org
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 net/irda/irsysctl.c |    6 +++---
 net/irda/qos.c      |    6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/irda/irsysctl.c b/net/irda/irsysctl.c
index d0b70da..2615ffc 100644
--- a/net/irda/irsysctl.c
+++ b/net/irda/irsysctl.c
@@ -40,9 +40,9 @@ extern int  sysctl_slot_timeout;
 extern int  sysctl_fast_poll_increase;
 extern char sysctl_devname[];
 extern int  sysctl_max_baud_rate;
-extern int  sysctl_min_tx_turn_time;
-extern int  sysctl_max_tx_data_size;
-extern int  sysctl_max_tx_window;
+extern unsigned int sysctl_min_tx_turn_time;
+extern unsigned int sysctl_max_tx_data_size;
+extern unsigned int sysctl_max_tx_window;
 extern int  sysctl_max_noreply_time;
 extern int  sysctl_warn_noreply_time;
 extern int  sysctl_lap_keepalive_time;
diff --git a/net/irda/qos.c b/net/irda/qos.c
index 1b51bcf..4369f7f 100644
--- a/net/irda/qos.c
+++ b/net/irda/qos.c
@@ -60,7 +60,7 @@ int sysctl_max_noreply_time = 12;
  * Default is 10us which means using the unmodified value given by the
  * peer except if it's 0 (0 is likely a bug in the other stack).
  */
-unsigned sysctl_min_tx_turn_time = 10;
+unsigned int sysctl_min_tx_turn_time = 10;
 /*
  * Maximum data size to be used in transmission in payload of LAP frame.
  * There is a bit of confusion in the IrDA spec :
@@ -75,13 +75,13 @@ unsigned sysctl_min_tx_turn_time = 10;
  * bytes frames or all negotiated frame sizes, but you can use the sysctl
  * to play with this value anyway.
  * Jean II */
-unsigned sysctl_max_tx_data_size = 2042;
+unsigned int sysctl_max_tx_data_size = 2042;
 /*
  * Maximum transmit window, i.e. number of LAP frames between turn-around.
  * This allow to override what the peer told us. Some peers are buggy and
  * don't always support what they tell us.
  * Jean II */
-unsigned sysctl_max_tx_window = 7;
+unsigned int sysctl_max_tx_window = 7;
 
 static int irlap_param_baud_rate(void *instance, irda_param_t *param, int get);
 static int irlap_param_link_disconnect(void *instance, irda_param_t *parm,
-- 
1.7.4.4

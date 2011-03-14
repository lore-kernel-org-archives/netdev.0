From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/7] tcp_cubic: make ack train delta value a parameter
Date: Mon, 14 Mar 2011 10:52:14 -0700
Message-ID: <20110314175439.471612260@vyatta.com>
References: <20110314175211.788224699@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58244 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757051Ab1CNSCD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 14:02:03 -0400
Content-Disposition: inline; filename=tcp-cubic-ackdelta.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the spacing between ACK's that indicates a train a tuneable
value like other hystart values.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/tcp_cubic.c	2011-03-14 08:19:15.697936023 -0700
+++ b/net/ipv4/tcp_cubic.c	2011-03-14 08:19:18.361944814 -0700
@@ -52,6 +52,7 @@ static int tcp_friendliness __read_mostl
 static int hystart __read_mostly = 1;
 static int hystart_detect __read_mostly = HYSTART_ACK_TRAIN | HYSTART_DELAY;
 static int hystart_low_window __read_mostly = 16;
+static int hystart_ack_delta __read_mostly = 2;
 
 static u32 cube_rtt_scale __read_mostly;
 static u32 beta_scale __read_mostly;
@@ -75,6 +76,8 @@ MODULE_PARM_DESC(hystart_detect, "hyrbri
 		 " 1: packet-train 2: delay 3: both packet-train and delay");
 module_param(hystart_low_window, int, 0644);
 MODULE_PARM_DESC(hystart_low_window, "lower bound cwnd for hybrid slow start");
+module_param(hystart_ack_delta, int, 0644);
+MODULE_PARM_DESC(hystart_ack_delta, "spacing between ack's indicating train (msecs)");
 
 /* BIC TCP Parameters */
 struct bictcp {
@@ -343,7 +346,7 @@ static void hystart_update(struct sock *
 
 		/* first detection parameter - ack-train detection */
 		if ((s32)(curr_jiffies - ca->last_jiffies) <=
-		    msecs_to_jiffies(2)) {
+		    msecs_to_jiffies(hystart_ack_delta)) {
 			ca->last_jiffies = curr_jiffies;
 			if ((s32) (curr_jiffies - ca->round_start) >
 			    ca->delay_min >> 4)



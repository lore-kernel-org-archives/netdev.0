From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/6] tcp_cubic: make ack train delta value a parameter
Date: Thu, 10 Mar 2011 08:51:26 -0800
Message-ID: <20110310165329.092807647@vyatta.com>
References: <20110310165119.224046957@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, sangtae.ha@gmail.com, rhee@ncsu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:45023 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753803Ab1CJQ4b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2011 11:56:31 -0500
Content-Disposition: inline; filename=tcp-cubic-ackdelta.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the spacing between ACK's that indicates a train a tuneable
value like other hystart values.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/tcp_cubic.c	2011-03-10 08:24:39.658201745 -0800
+++ b/net/ipv4/tcp_cubic.c	2011-03-10 08:25:28.078700603 -0800
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
 			if ((s32) (curr_jiffies - ca->round_start) <=
 			    ca->delay_min >> 4)



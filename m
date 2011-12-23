From: Stephen Hemminger <shemminger@vyatta.com>
Subject: netem: loss model API sizes
Date: Fri, 23 Dec 2011 11:16:30 -0800
Message-ID: <20111223111630.52f9f6d7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42609 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752841Ab1LWTQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Dec 2011 14:16:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new netem loss model is configured with nested netlink messages.
This code is being overly strict about sizes, and is easily confused
by padding (or possible future expansion). Also message
for gemodel is incorrect.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/sched/sch_netem.c	2011-08-01 14:13:55.000000000 -0700
+++ b/net/sched/sch_netem.c	2011-12-22 16:57:35.310210173 -0800
@@ -548,7 +548,7 @@ static int get_loss_clg(struct Qdisc *sc
 		case NETEM_LOSS_GI: {
 			const struct tc_netem_gimodel *gi = nla_data(la);
 
-			if (nla_len(la) != sizeof(struct tc_netem_gimodel)) {
+			if (nla_len(la) < sizeof(struct tc_netem_gimodel)) {
 				pr_info("netem: incorrect gi model size\n");
 				return -EINVAL;
 			}
@@ -567,8 +567,8 @@ static int get_loss_clg(struct Qdisc *sc
 		case NETEM_LOSS_GE: {
 			const struct tc_netem_gemodel *ge = nla_data(la);
 
-			if (nla_len(la) != sizeof(struct tc_netem_gemodel)) {
-				pr_info("netem: incorrect gi model size\n");
+			if (nla_len(la) < sizeof(struct tc_netem_gemodel)) {
+				pr_info("netem: incorrect ge model size\n");
 				return -EINVAL;
 			}
 

From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH iproute2] netem: Fail cleanly if user input is wrong
Date: Fri, 20 Jan 2012 09:50:25 -0800
Message-ID: <1327081825-6448-1-git-send-email-subramanian.vijay@gmail.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:55441 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753889Ab2ATRv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 12:51:57 -0500
Received: by iaeh11 with SMTP id h11so610215iae.19
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2012 09:51:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Resending patch since it looks like my earlier mail did not make it to
netdev). 

netem reordering requires that the delay parameter be given. Currently, if no
delay is given, tc prints the error message but still installs the qdisc. Fix
this by printing the usage and failing cleanly.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 tc/q_netem.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/tc/q_netem.c b/tc/q_netem.c
index b1fd452..23164d9 100644
--- a/tc/q_netem.c
+++ b/tc/q_netem.c
@@ -395,6 +395,8 @@ static int netem_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	if (reorder.probability) {
 		if (opt.latency == 0) {
 			fprintf(stderr, "reordering not possible without specifying some delay\n");
+			explain();
+			return -1;
 		}
 		if (opt.gap == 0)
 			opt.gap = 1;
-- 
1.7.0.4

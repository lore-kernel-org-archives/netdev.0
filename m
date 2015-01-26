From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH iproute2] ss: group DCTCP socket statistics
Date: Mon, 26 Jan 2015 23:17:39 +0100
Message-ID: <1422310659-9357-1-git-send-email-hagen@jauu.net>
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:39724 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755308AbbAZWQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 17:16:08 -0500
Received: by mail-we0-f175.google.com with SMTP id p10so11709514wes.6
        for <netdev@vger.kernel.org>; Mon, 26 Jan 2015 14:16:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Keep ss output consistent and format DCTCP socket statistics similar to skmen
and timer where a group of logical values are grouped by brackets. This makes
parser scripts *and* humans more happy.


Current output of 'ss -inetm dst :80':
ESTAB       0      0 192.168.11.14:55511 173.194.66.189:443
	timer:(keepalive,14sec,0) uid:1000 ino:428768
	sk:ffff88020ceb5b00 <-> skmem:(r0,rb372480,t0,tb87040,f0,w0,o0,bl0)
	ts sack wscale:7,7 rto:250 rtt:49.225/20.837 ato:40 mss:1408 cwnd:10
	ce_state 23 alpha 23 ab_ecn 23 ab_tot 23 send 2.3Mbps
	lastsnd:121026 lastrcv:121026 lastack:30850 pacing_rate 4.6Mbps
	retrans:0/2 rcv_rtt:40.416 rcv_space:2920

New grouped output:
ESTAB       0      0 192.168.11.14:55511 173.194.66.189:443
	timer:(keepalive,14sec,0) uid:1000 ino:428768
	sk:ffff88020ceb5b00 <-> skmem:(r0,rb372480,t0,tb87040,f0,w0,o0,bl0)
	ts sack wscale:7,7 rto:250 rtt:49.225/20.837 ato:40 mss:1408 cwnd:10
	dctcp(ce_state:23,alpha:23,ab_ecn:23,ab_tot:23) send 2.3Mbps
	lastsnd:121026 lastrcv:121026 lastack:30850 pacing_rate 4.6Mbps
	retrans:0/2 rcv_rtt:40.416 rcv_space:2920

Cc: Stephen Hemminger <stephen@networkplumber.org>
Acked-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 misc/ss.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index f434f57..7d02650 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1713,11 +1713,11 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 				= RTA_DATA(tb[INET_DIAG_DCTCPINFO]);
 
 			if (dinfo->dctcp_enabled) {
-				printf(" ce_state %u alpha %u ab_ecn %u ab_tot %u",
+				printf("dctcp:(ce_state:%u,alpha:%u,ab_ecn:%u,ab_tot:%u)",
 				       dinfo->dctcp_ce_state, dinfo->dctcp_alpha,
 				       dinfo->dctcp_ab_ecn, dinfo->dctcp_ab_tot);
 			} else {
-				printf(" fallback_mode");
+				printf("dctcp:fallback_mode");
 			}
 		}
 
-- 
2.2.2

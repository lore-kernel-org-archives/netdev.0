From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH iproute2] ss: group DCTCP socket statistics
Date: Tue, 24 Feb 2015 22:24:51 +0100
Message-ID: <1424813091-5750-1-git-send-email-hagen@jauu.net>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Hagen Paul Pfeifer <hagen@jauu.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:41533 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751682AbbBXVZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 16:25:31 -0500
Received: by wghl18 with SMTP id l18so8050839wgh.8
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 13:25:30 -0800 (PST)
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
index 2678033..a2319d9 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1680,11 +1680,11 @@ static void tcp_stats_print(struct tcpstat *s)
 	if (s->dctcp && s->dctcp->enabled) {
 		struct dctcpstat *dctcp = s->dctcp;
 
-		printf(" ce_state %u alpha %u ab_ecn %u ab_tot %u",
+		printf("dctcp:(ce_state:%u,alpha:%u,ab_ecn:%u,ab_tot:%u)",
 				dctcp->ce_state, dctcp->alpha, dctcp->ab_ecn,
 				dctcp->ab_tot);
 	} else if (s->dctcp) {
-		printf(" fallback_mode");
+		printf("dctcp:fallback_mode");
 	}
 
 	if (s->send_bps)
-- 
2.1.4

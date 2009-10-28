From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: [PATCHv4 1/7] Only parse time stamp TCP option in time wait sock
Date: Wed, 28 Oct 2009 16:15:21 +0200
Message-ID: <1256739327-11576-2-git-send-email-gilad@codefidence.com>
References: <1256739327-11576-1-git-send-email-gilad@codefidence.com>
Cc: ori@comsleep.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:58560 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753961AbZJ1OPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 10:15:36 -0400
In-Reply-To: <1256739327-11576-1-git-send-email-gilad@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we only use tcp_parse_options here to check for the exietence
of TCP timestamp option in the header, it is better to call with
the "established" flag on.

Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
Signed-off-by: Ori Finkelman <ori@comsleep.com>
Signed-off-by: Yony Amit <yony@comsleep.com>
---
 net/ipv4/tcp_minisocks.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 624c3c9..8c8c6e6 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -100,9 +100,9 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
 	struct tcp_options_received tmp_opt;
 	int paws_reject = 0;
 
-	tmp_opt.saw_tstamp = 0;
 	if (th->doff > (sizeof(*th) >> 2) && tcptw->tw_ts_recent_stamp) {
-		tcp_parse_options(skb, &tmp_opt, 0);
+		tmp_opt.tstamp_ok = 1;
+		tcp_parse_options(skb, &tmp_opt, 1);
 
 		if (tmp_opt.saw_tstamp) {
 			tmp_opt.ts_recent	= tcptw->tw_ts_recent;
-- 
1.5.6.3


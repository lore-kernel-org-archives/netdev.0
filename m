From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ss: take care of unknown min_rtt
Date: Wed, 13 Apr 2016 15:18:38 -0700
Message-ID: <1460585918.10638.42.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33775 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754276AbcDMWSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 18:18:41 -0400
Received: by mail-pf0-f180.google.com with SMTP id 184so39303157pff.0
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 15:18:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Kernel sets info->tcpi_min_rtt to ~0U when no RTT sample was ever
taken for the session, thus min_rtt is unknown.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 misc/ss.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index 38cf331..51ff5ac 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2018,7 +2018,8 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 		s.segs_out = info->tcpi_segs_out;
 		s.segs_in = info->tcpi_segs_in;
 		s.not_sent = info->tcpi_notsent_bytes;
-		s.min_rtt = (double) info->tcpi_min_rtt / 1000;
+		if (info->tcpi_min_rtt && info->tcpi_min_rtt != ~0U)
+			s.min_rtt = (double) info->tcpi_min_rtt / 1000;
 		tcp_stats_print(&s);
 		free(s.dctcp);
 	}

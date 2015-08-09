From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: [PATCH 10/10] ss: fixed free on local array for valid json output
Date: Mon, 10 Aug 2015 01:13:26 +0200
Message-ID: <1439162006-11421-11-git-send-email-matthias.tafelmeier@gmx.net>
References: <1439162006-11421-1-git-send-email-matthias.tafelmeier@gmx.net>
Cc: hagen@jauu.net, shemminger@osdl.org, fw@strlen.de,
	edumazet@google.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:63381 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751869AbbHIXN7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Aug 2015 19:13:59 -0400
In-Reply-To: <1439162006-11421-1-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor fix to enable json output. Freeing of automatic char array name
which will get freed after function stack cleanup. Another one after
tcp_stats_fmt for freeing automatic tcpstats struct instance.

Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Suggested-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 misc/ss.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 24f08d0..dc6e3f1 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1665,10 +1665,6 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 		s.segs_out = info->tcpi_segs_out;
 		s.segs_in = info->tcpi_segs_in;
 		tcp_stats_fmt(&s);
-		if (s.dctcp)
-			free(s.dctcp);
-		if (s.cong_alg)
-			free(s.cong_alg);
 	}
 }
 
@@ -2367,8 +2363,6 @@ if (show_mem) {
 		printf("}\n");
 	}
 
-	if (name)
-		free(name);
 	return 0;
 }
 
-- 
1.9.1

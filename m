From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: [PATCH v7 09/10] ss: fixed free on local array for valid json output
Date: Thu, 10 Sep 2015 21:35:07 +0200
Message-ID: <1441913708-15532-10-git-send-email-matthias.tafelmeier@gmx.net>
References: <1441913708-15532-1-git-send-email-matthias.tafelmeier@gmx.net>
Cc: hagen@jauu.net, shemminger@osdl.org, fw@strlen.de,
	edumazet@google.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:57859 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752859AbbIJTfj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Sep 2015 15:35:39 -0400
In-Reply-To: <1441913708-15532-1-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor fix to enable json output. Freeing of automatic char array name
which will get freed after function stack cleanup. Another one after
tcp_stats_fmt for freeing automatic tcpstats struct instance.

Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
---
 misc/ss.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 6ff40a3..80aebe6 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1660,10 +1660,6 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 		s.segs_out = info->tcpi_segs_out;
 		s.segs_in = info->tcpi_segs_in;
 		tcp_stats_fmt(&s);
-		if (s.dctcp)
-			free(s.dctcp);
-		if (s.cong_alg)
-			free(s.cong_alg);
 	}
 }
 
@@ -2362,8 +2358,6 @@ static int unix_show_sock(const struct sockaddr_nl *addr, struct nlmsghdr *nlh,
 	if (json_output)
 		jsonw_end_object(json_wr);
 
-	if (name)
-		free(name);
 	return 0;
 }
 
-- 
1.9.1

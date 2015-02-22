From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 2/2] ss: Skip filtered netlink sockets before detailed info
Date: Sun, 22 Feb 2015 22:23:11 +0200
Message-ID: <1424636591-19903-3-git-send-email-vadim4j@gmail.com>
References: <1424636591-19903-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:47032 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752021AbbBVUea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2015 15:34:30 -0500
Received: by lbjf15 with SMTP id f15so14910684lbj.13
        for <netdev@vger.kernel.org>; Sun, 22 Feb 2015 12:34:28 -0800 (PST)
In-Reply-To: <1424636591-19903-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 5320d38..5113d85 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2938,7 +2938,7 @@ static int packet_show(struct filter *f)
 	return 0;
 }
 
-static void netlink_show_one(struct filter *f,
+static int netlink_show_one(struct filter *f,
 				int prot, int pid, unsigned groups,
 				int state, int dst_pid, unsigned dst_group,
 				int rq, int wq,
@@ -2960,7 +2960,7 @@ static void netlink_show_one(struct filter *f,
 		st.lport = pid;
 		st.local.data[0] = prot;
 		if (run_ssfilter(f->f, &st) == 0)
-			return;
+			return 1;
 	}
 
 	sock_state_print(&st, "nl");
@@ -3032,7 +3032,7 @@ static void netlink_show_one(struct filter *f,
 	}
 	printf("\n");
 
-	return;
+	return 0;
 }
 
 static int netlink_show_sock(const struct sockaddr_nl *addr,
@@ -3058,9 +3058,11 @@ static int netlink_show_sock(const struct sockaddr_nl *addr,
 		wq = skmeminfo[SK_MEMINFO_WMEM_ALLOC];
 	}
 
-	netlink_show_one(f, r->ndiag_protocol, r->ndiag_portid, groups,
+	if (netlink_show_one(f, r->ndiag_protocol, r->ndiag_portid, groups,
 			 r->ndiag_state, r->ndiag_dst_portid, r->ndiag_dst_group,
-			 rq, wq, 0, 0);
+			 rq, wq, 0, 0)) {
+		return 0;
+	}
 
 	if (show_mem) {
 		printf("\t");
-- 
2.2.2

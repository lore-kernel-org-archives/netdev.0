From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ip monitor: Fixed printing timestamp few times
Date: Mon,  1 Dec 2014 01:14:22 +0200
Message-ID: <1417389262-25189-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:63948 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752208AbaK3XYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2014 18:24:03 -0500
Received: by mail-wi0-f182.google.com with SMTP id h11so15607633wiw.15
        for <netdev@vger.kernel.org>; Sun, 30 Nov 2014 15:24:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another fix when timestamp is printed few times
before the event message.

Fixed by skipping the message types which are not supported.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/ipmonitor.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 4cc75f4..5c3ed18 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -42,6 +42,15 @@ static int accept_msg(const struct sockaddr_nl *who,
 {
 	FILE *fp = (FILE*)arg;
 
+	if (n->nlmsg_type == RTM_NEWQDISC ||
+	    n->nlmsg_type == RTM_DELQDISC ||
+	    n->nlmsg_type == RTM_NEWTCLASS ||
+	    n->nlmsg_type == RTM_DELTCLASS ||
+	    n->nlmsg_type == RTM_NEWTFILTER ||
+	    n->nlmsg_type == RTM_DELTFILTER ||
+	    n->nlmsg_type == RTM_NEWNDUSEROPT)
+		return 0;
+
 	if (n->nlmsg_type == RTM_NEWROUTE || n->nlmsg_type == RTM_DELROUTE) {
 		struct rtmsg *r = NLMSG_DATA(n);
 		int len = n->nlmsg_len - NLMSG_LENGTH(sizeof(*r));
@@ -134,14 +143,6 @@ static int accept_msg(const struct sockaddr_nl *who,
 		fprintf(fp, "Timestamp: %s %lu us\n", tstr, usecs);
 		return 0;
 	}
-	if (n->nlmsg_type == RTM_NEWQDISC ||
-	    n->nlmsg_type == RTM_DELQDISC ||
-	    n->nlmsg_type == RTM_NEWTCLASS ||
-	    n->nlmsg_type == RTM_DELTCLASS ||
-	    n->nlmsg_type == RTM_NEWTFILTER ||
-	    n->nlmsg_type == RTM_DELTFILTER ||
-	    n->nlmsg_type == RTM_NEWNDUSEROPT)
-		return 0;
 	if (n->nlmsg_type != NLMSG_ERROR && n->nlmsg_type != NLMSG_NOOP &&
 	    n->nlmsg_type != NLMSG_DONE) {
 		fprintf(fp, "Unknown message: type=0x%08x(%d) flags=0x%08x(%d)"
-- 
2.1.3

From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ip monitor: Changed 'Unknown message' format to be more informative
Date: Tue, 16 Sep 2014 21:23:50 +0300
Message-ID: <1410891830-4556-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:40352 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754576AbaIPScI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 14:32:08 -0400
Received: by mail-la0-f54.google.com with SMTP id ge10so344613lab.41
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 11:32:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case if unknown message was handled then it will be displayed as:

    Unknown message: type=0x00000044(68) flags=0x00000000(0) len=0x0000004c(76)

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/ipmonitor.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 70f2a7a..838934d 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -135,8 +135,10 @@ static int accept_msg(const struct sockaddr_nl *who,
 		return 0;
 	if (n->nlmsg_type != NLMSG_ERROR && n->nlmsg_type != NLMSG_NOOP &&
 	    n->nlmsg_type != NLMSG_DONE) {
-		fprintf(fp, "Unknown message: %08x %08x %08x\n",
-			n->nlmsg_len, n->nlmsg_type, n->nlmsg_flags);
+		fprintf(fp, "Unknown message: type=0x%08x(%d) flags=0x%08x(%d)"
+			"len=0x%08x(%d)\n", n->nlmsg_type, n->nlmsg_type,
+		       	n->nlmsg_flags, n->nlmsg_flags, n->nlmsg_len,
+		       	n->nlmsg_len);
 	}
 	return 0;
 }
-- 
2.1.0

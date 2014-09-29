From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 v2] ip monitor: Changed 'Unknown message' format to be more informative
Date: Mon, 29 Sep 2014 23:07:57 +0300
Message-ID: <1412021277-24020-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:44351 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751688AbaI2UQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 16:16:29 -0400
Received: by mail-lb0-f177.google.com with SMTP id w7so1916431lbi.22
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 13:16:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case if unknown message was handled then it will be displayed as:

    Unknown message: type=0x00000044(68) flags=0x00000000(0) len=0x0000004c(76)

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/ipmonitor.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 088ec54..b7b2d98 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -143,8 +143,10 @@ static int accept_msg(const struct sockaddr_nl *who,
 		return 0;
 	if (n->nlmsg_type != NLMSG_ERROR && n->nlmsg_type != NLMSG_NOOP &&
 	    n->nlmsg_type != NLMSG_DONE) {
-		fprintf(fp, "Unknown message: %08x %08x %08x\n",
-			n->nlmsg_len, n->nlmsg_type, n->nlmsg_flags);
+		fprintf(fp, "Unknown message: type=0x%08x(%d) flags=0x%08x(%d)"
+			"len=0x%08x(%d)\n", n->nlmsg_type, n->nlmsg_type,
+			n->nlmsg_flags, n->nlmsg_flags, n->nlmsg_len,
+			n->nlmsg_len);
 	}
 	return 0;
 }
-- 
2.1.0

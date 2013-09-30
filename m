From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 4/4] connector - documentation: simplify netlink message length assignment
Date: Mon, 30 Sep 2013 22:03:09 +0200
Message-ID: <1380571389-15343-5-git-send-email-minipli@googlemail.com>
References: <1380571389-15343-1-git-send-email-minipli@googlemail.com>
Cc: Mathias Krause <minipli@googlemail.com>, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f41.google.com ([209.85.214.41]:51138 "EHLO
	mail-bk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756406Ab3I3UD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 16:03:29 -0400
Received: by mail-bk0-f41.google.com with SMTP id na10so2366856bkb.28
        for <netdev@vger.kernel.org>; Mon, 30 Sep 2013 13:03:27 -0700 (PDT)
In-Reply-To: <1380571389-15343-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the precalculated size instead of obfuscating the message length
calculation by first subtracting the netlink header length from size
and then use the NLMSG_LENGTH() macro to add it back again.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 Documentation/connector/ucon.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/connector/ucon.c b/Documentation/connector/ucon.c
index 4848db8..8a4da64 100644
--- a/Documentation/connector/ucon.c
+++ b/Documentation/connector/ucon.c
@@ -71,7 +71,7 @@ static int netlink_send(int s, struct cn_msg *msg)
 	nlh->nlmsg_seq = seq++;
 	nlh->nlmsg_pid = getpid();
 	nlh->nlmsg_type = NLMSG_DONE;
-	nlh->nlmsg_len = NLMSG_LENGTH(size - sizeof(*nlh));
+	nlh->nlmsg_len = size;
 	nlh->nlmsg_flags = 0;
 
 	m = NLMSG_DATA(nlh);
-- 
1.7.10.4

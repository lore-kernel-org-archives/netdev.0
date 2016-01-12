From: Baozeng Ding <sploving1@gmail.com>
Subject: [PATCH v3] netlink: fix null pointer dereference on nlk->groups
Date: Tue, 12 Jan 2016 19:10:43 +0800
Message-ID: <1452597043-4298-1-git-send-email-sploving1@gmail.com>
References: <1452231970-27357-1-git-send-email-sploving1@gmail.com>
Cc: netdev@vger.kernel.org, Baozeng Ding <sploving1@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34708 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934758AbcALLMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 06:12:05 -0500
Received: by mail-pa0-f66.google.com with SMTP id yy13so25698943pab.1
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 03:12:04 -0800 (PST)
In-Reply-To: <1452231970-27357-1-git-send-email-sploving1@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If groups is not 0 and nlk->groups is NULL, it will not return
immediately and cause a null pointer dereference later.

Signed-off-by: Baozeng Ding <sploving1@gmail.com>
---
The v3 version adds WARN_ON, suggested by David Miller. Thanks for
David's feedback.
---
 net/netlink/af_netlink.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 59651af..f93d579 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1576,7 +1576,10 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 		}
 	}
 
-	if (!groups && (nlk->groups == NULL || !(u32)nlk->groups[0]))
+	if (WARN_ON(!nlk->groups))
+		return 0;
+
+	if (!groups && !(u32)nlk->groups[0])
 		return 0;
 
 	netlink_table_grab();
-- 
1.9.1

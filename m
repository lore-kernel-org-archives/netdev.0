From: Baozeng Ding <sploving1@gmail.com>
Subject: [PATCH v2] netlink: fix null pointer dereference on nlk->groups
Date: Sat,  9 Jan 2016 23:56:41 +0800
Message-ID: <1452355001-30295-1-git-send-email-sploving1@gmail.com>
References: <1452231970-27357-1-git-send-email-sploving1@gmail.com>
Cc: netdev@vger.kernel.org, Baozeng Ding <sploving1@gmail.com>
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35287 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754033AbcAIP4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 10:56:50 -0500
Received: by mail-pf0-f196.google.com with SMTP id 65so1913575pff.2
        for <netdev@vger.kernel.org>; Sat, 09 Jan 2016 07:56:49 -0800 (PST)
In-Reply-To: <1452231970-27357-1-git-send-email-sploving1@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If groups is not 0 and nlk->groups is NULL, it will not return
immediately and cause a null pointer dereference later.

Signed-off-by: Baozeng Ding <sploving1@gmail.com>
---
This version uses the preferred networking coding style. Thanks
for Sergei's feedback. Also the patch keeps the original author's
coding style as much as possible.
---
 net/netlink/af_netlink.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 59651af..eeff14a 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1576,7 +1576,10 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 		}
 	}
 
-	if (!groups && (nlk->groups == NULL || !(u32)nlk->groups[0]))
+	if (!nlk->groups)
+		return 0;
+
+	if (!groups && !(u32)nlk->groups[0])
 		return 0;
 
 	netlink_table_grab();
-- 
1.9.1

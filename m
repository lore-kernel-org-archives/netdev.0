From: Alexander Heinlein <alexander.heinlein@secunet.com>
Subject: [PATCH] ip/xfrm: Fix deleteall when having many policies installed
Date: Mon, 16 Jan 2017 15:09:01 +0100
Message-ID: <d056322e-7c23-7e19-3bdb-4afa5f04e409@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <shemminger@osdl.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:40572 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750831AbdAPOJE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 09:09:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix "Policy buffer overflow" error when trying to use deleteall with
many policies installed.

Signed-off-by: Alexander Heinlein <alexander.heinlein@secunet.com>
---
 ip/xfrm_policy.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index cc9c0f1..451b982 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -732,10 +732,8 @@ static int xfrm_policy_keep(const struct
sockaddr_nl *who,
 	if (!xfrm_policy_filter_match(xpinfo, ptype))
 		return 0;

-	if (xb->offset > xb->size) {
-		fprintf(stderr, "Policy buffer overflow\n");
-		return -1;
-	}
+	if (xb->offset + NLMSG_LENGTH(sizeof(*xpid)) > xb->size)
+		return 0;

 	new_n = (struct nlmsghdr *)(xb->buf + xb->offset);
 	new_n->nlmsg_len = NLMSG_LENGTH(sizeof(*xpid));
-- 
2.1.4

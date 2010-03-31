From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH 2/4] xfrm_user: verify policy direction at XFRM_MSG_POLEXPIRE handler
Date: Wed, 31 Mar 2010 13:17:04 +0300
Message-ID: <1270030626-16687-4-git-send-email-timo.teras@iki.fi>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:59811 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933202Ab0CaKR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 06:17:28 -0400
Received: by ey-out-2122.google.com with SMTP id d26so1356113eyd.19
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 03:17:27 -0700 (PDT)
In-Reply-To: <1270030626-16687-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing check for policy direction verification. This is
especially important since without this xfrm_user may end up
deleting per-socket policy which is not allowed.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
---
 net/xfrm/xfrm_user.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 6106b72..da5ba86 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1741,6 +1741,10 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (err)
 		return err;
 
+	err = verify_policy_dir(p->dir);
+	if (err)
+		return err;
+
 	if (p->index)
 		xp = xfrm_policy_byid(net, mark, type, p->dir, p->index, 0, &err);
 	else {
-- 
1.6.3.3


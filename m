From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH] xfrm: Add a XFRM_STATE_AF_UNSPEC flag to xfrm_usersa_info
Date: Thu, 10 Jul 2008 13:29:01 +0200
Message-ID: <20080710112901.GV9549@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:57598 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754779AbYGJL3D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 07:29:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a XFRM_STATE_AF_UNSPEC flag to handle the AF_UNSPEC behavior
for the selector family. Userspace applications can set this flag
to leave the selector family of the xfrm_state unspecified.
This can be used to to handle inter family tunnels if the
selector is not set from userspace.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/linux/xfrm.h |    1 +
 net/xfrm/xfrm_user.c |    3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 2ca6bae..fb0c215 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -339,6 +339,7 @@ struct xfrm_usersa_info {
 #define XFRM_STATE_NOPMTUDISC	4
 #define XFRM_STATE_WILDRECV	8
 #define XFRM_STATE_ICMP		16
+#define XFRM_STATE_AF_UNSPEC	32
 };
 
 struct xfrm_usersa_id {
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index b976d9e..04c4150 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -277,9 +277,8 @@ static void copy_from_user_state(struct xfrm_state *x, struct xfrm_usersa_info *
 	memcpy(&x->props.saddr, &p->saddr, sizeof(x->props.saddr));
 	x->props.flags = p->flags;
 
-	if (!x->sel.family)
+	if (!x->sel.family && !(p->flags & XFRM_STATE_AF_UNSPEC))
 		x->sel.family = p->family;
-
 }
 
 /*
-- 
1.5.3


From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 3/6] xfrm_user: fix info leak in copy_to_user_policy()
Date: Wed, 19 Sep 2012 23:33:40 +0200
Message-ID: <1348090423-32665-4-git-send-email-minipli@googlemail.com>
References: <1348090423-32665-1-git-send-email-minipli@googlemail.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mathias Krause <minipli@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1348090423-32665-1-git-send-email-minipli@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The memory reserved to dump the xfrm policy includes multiple padding
bytes added by the compiler for alignment (padding bytes in struct
xfrm_selector and struct xfrm_userpolicy_info). Add an explicit
memset(0) before filling the buffer to avoid the heap info leak.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/xfrm/xfrm_user.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index c1f15b5..7511427 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1318,6 +1318,7 @@ static void copy_from_user_policy(struct xfrm_policy *xp, struct xfrm_userpolicy
 
 static void copy_to_user_policy(struct xfrm_policy *xp, struct xfrm_userpolicy_info *p, int dir)
 {
+	memset(p, 0, sizeof(*p));
 	memcpy(&p->sel, &xp->selector, sizeof(p->sel));
 	memcpy(&p->lft, &xp->lft, sizeof(p->lft));
 	memcpy(&p->curlft, &xp->curlft, sizeof(p->curlft));
-- 
1.7.10.4

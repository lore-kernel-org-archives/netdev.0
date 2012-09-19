From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 4/6] xfrm_user: fix info leak in copy_to_user_tmpl()
Date: Wed, 19 Sep 2012 23:33:41 +0200
Message-ID: <1348090423-32665-5-git-send-email-minipli@googlemail.com>
References: <1348090423-32665-1-git-send-email-minipli@googlemail.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mathias Krause <minipli@googlemail.com>,
	Brad Spengler <spender@grsecurity.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1348090423-32665-1-git-send-email-minipli@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The memory used for the template copy is a local stack variable. As
struct xfrm_user_tmpl contains multiple holes added by the compiler for
alignment, not initializing the memory will lead to leaking stack bytes
to userland. Add an explicit memset(0) to avoid the info leak.

Initial version of the patch by Brad Spengler.

Cc: Brad Spengler <spender@grsecurity.net>
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/xfrm/xfrm_user.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 7511427..9f1e749 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1423,6 +1423,7 @@ static int copy_to_user_tmpl(struct xfrm_policy *xp, struct sk_buff *skb)
 		struct xfrm_user_tmpl *up = &vec[i];
 		struct xfrm_tmpl *kp = &xp->xfrm_vec[i];
 
+		memset(up, 0, sizeof(*up));
 		memcpy(&up->id, &kp->id, sizeof(up->id));
 		up->family = kp->encap_family;
 		memcpy(&up->saddr, &kp->saddr, sizeof(up->saddr));
-- 
1.7.10.4

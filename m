From: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH] xprtrdma: add missing curly braces, set rc to zero on non-zero
Date: Tue, 24 Nov 2015 23:11:41 +0000
Message-ID: <1448406701-12474-1-git-send-email-colin.king@canonical.com>
To: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J . Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Sagi Grimberg <sagig-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

Add the missing curly braces so that rc is only set to zero when
it is non-zero.  Without this minor fix, rc is set to zero even
when it is zero, which is slightly redundant.

Detected with smatch static analysis.

Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 net/sunrpc/xprtrdma/verbs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index eadd1655..2cc1014 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -852,10 +852,11 @@ retry:
 
 		if (extras) {
 			rc = rpcrdma_ep_post_extra_recv(r_xprt, extras);
-			if (rc)
+			if (rc) {
 				pr_warn("%s: rpcrdma_ep_post_extra_recv: %i\n",
 					__func__, rc);
 				rc = 0;
+			}
 		}
 	}
 
-- 
2.6.2

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

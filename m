From: Peter Senna Tschudin <peter.senna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/11] cw1200: Remove useless return variables
Date: Sat, 31 May 2014 10:14:02 -0300
Message-ID: <1401542051-3174-2-git-send-email-peter.senna@gmail.com>
Cc: kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Solomon Peachy <pizza-pCgMCH4qpMRg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch remove variables that are initialized with a constant,
are never updated, and are only used as parameter of return.
Return the constant instead of using a variable.

Verified by compilation only.

The coccinelle script that find and fixes this issue is:
// <smpl>
@@
type T;
constant C;
identifier ret;
@@
- T ret = C;
... when != ret
    when strict
return
- ret
+ C
;
// </smpl>

Signed-off-by: Peter Senna Tschudin <peter.senna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

---
 drivers/net/wireless/cw1200/sta.c |   19 +------------------
 1 file changed, 1 insertion(+), 18 deletions(-)

diff --git a/drivers/net/wireless/cw1200/sta.c b/drivers/net/wireless/cw1200/sta.c
index cd0cad7..622370c 100644
--- a/drivers/net/wireless/cw1200/sta.c
+++ b/drivers/net/wireless/cw1200/sta.c
@@ -2289,24 +2289,7 @@ static int cw1200_upload_null(struct cw1200_common *priv)
 
 static int cw1200_upload_qosnull(struct cw1200_common *priv)
 {
-	int ret = 0;
-	/* TODO:  This needs to be implemented
-
-	struct wsm_template_frame frame = {
-		.frame_type = WSM_FRAME_TYPE_QOS_NULL,
-		.rate = 0xFF,
-	};
-
-	frame.skb = ieee80211_qosnullfunc_get(priv->hw, priv->vif);
-	if (!frame.skb)
-		return -ENOMEM;
-
-	ret = wsm_set_template_frame(priv, &frame);
-
-	dev_kfree_skb(frame.skb);

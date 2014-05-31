From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 2/11 V2] cw1200: Remove useless return variables
Date: Sat, 31 May 2014 13:12:26 -0300
Message-ID: <1401552746-10615-1-git-send-email-peter.senna@gmail.com>
Cc: kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Solomon Peachy <pizza@shaftnet.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
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

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

---
Changes from V1:
- Keep commented code instead of removing it

 drivers/net/wireless/cw1200/sta.c |   19 +------------------
 1 file changed, 1 insertion(+), 18 deletions(-)

diff --git a/drivers/net/wireless/cw1200/sta.c b/drivers/net/wireless/cw1200/sta.c
index cd0cad7..5b84664 100644
--- a/drivers/net/wireless/cw1200/sta.c
+++ b/drivers/net/wireless/cw1200/sta.c
@@ -2289,7 +2289,6 @@ static int cw1200_upload_null(struct cw1200_common *priv)
 
 static int cw1200_upload_qosnull(struct cw1200_common *priv)
 {
-	int ret = 0;
 	/* TODO:  This needs to be implemented
 
 	struct wsm_template_frame frame = {
@@ -2306,7 +2305,7 @@ static int cw1200_upload_qosnull(struct cw1200_common *priv)
 	dev_kfree_skb(frame.skb);
 
 	*/
-	return ret;
+	return 0;
 }
 
 static int cw1200_enable_beaconing(struct cw1200_common *priv,

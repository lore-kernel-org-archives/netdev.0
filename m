From: Insu Yun <wuninsu@gmail.com>
Subject: [PATCH 1/2] isdn: correctly check failed allocation
Date: Thu, 15 Oct 2015 12:29:27 -0400
Message-ID: <1444926568-29572-1-git-send-email-wuninsu@gmail.com>
Cc: taesoo@gatech.edu, yeongjin.jang@gatech.edu, insu@gatech.edu,
	Insu Yun <wuninsu@gmail.com>
To: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since skb_clone can be failed in memory pressure,
return value of skb_clone needs to be checked.

Signed-off-by: Insu Yun <wuninsu@gmail.com>
---
 drivers/isdn/hisax/isdnl2.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/isdn/hisax/isdnl2.c b/drivers/isdn/hisax/isdnl2.c
index 18accb0..e74f847 100644
--- a/drivers/isdn/hisax/isdnl2.c
+++ b/drivers/isdn/hisax/isdnl2.c
@@ -1284,6 +1284,10 @@ l2_pull_iqueue(struct FsmInst *fi, int event, void *arg)
 	}
 	l2->windowar[p1] = skb_clone(skb, GFP_ATOMIC);
 
+  if (!l2->windowar[p1]) {
+    return;
+  }
+
 	i = sethdraddr(&st->l2, header, CMD);
 
 	if (test_bit(FLG_MOD128, &l2->flag)) {
-- 
1.9.1

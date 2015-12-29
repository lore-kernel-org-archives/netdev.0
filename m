From: Insu Yun <wuninsu@gmail.com>
Subject: [PATCH] mISDN: correctly handling failed allocation in fsm
Date: Tue, 29 Dec 2015 16:41:33 -0500
Message-ID: <1451425293-30262-1-git-send-email-wuninsu@gmail.com>
Cc: taesoo@gatech.edu, yeongjin.jang@gatech.edu, insu@gatech.edu,
	changwoo@gatech.edu, Insu Yun <wuninsu@gmail.com>
To: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since kzalloc can be failed in memory pressure,
NULL dereference can be happened.

Signed-off-by: Insu Yun <wuninsu@gmail.com>
---
 drivers/isdn/mISDN/fsm.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/isdn/mISDN/fsm.c b/drivers/isdn/mISDN/fsm.c
index 26477d4..3c3ffb0 100644
--- a/drivers/isdn/mISDN/fsm.c
+++ b/drivers/isdn/mISDN/fsm.c
@@ -34,6 +34,8 @@ mISDN_FsmNew(struct Fsm *fsm,
 
 	fsm->jumpmatrix = kzalloc(sizeof(FSMFNPTR) * fsm->state_count *
 				  fsm->event_count, GFP_KERNEL);
+	if (!fsm->jumpmatrix)
+		return;
 
 	for (i = 0; i < fncount; i++)
 		if ((fnlist[i].state >= fsm->state_count) ||
-- 
1.9.1

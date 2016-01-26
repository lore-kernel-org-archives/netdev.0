From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: [PATCH] isdn: Remove unnecessary cast in kfree
Date: Wed, 27 Jan 2016 00:06:01 +0530
Message-ID: <20160126183601.GA29611@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove unnecassary casts in the argument to kfree.

Found using Coccinelle. The semantic patch used to find this is as follows:

//<smpl>
@@
type T;
expression *f;
@@

- kfree((T *)(f));
+ kfree(f);
//</smpl>

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
 drivers/isdn/hisax/fsm.c | 2 +-
 drivers/isdn/mISDN/fsm.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hisax/fsm.c b/drivers/isdn/hisax/fsm.c
index c7a9471..497f815 100644
--- a/drivers/isdn/hisax/fsm.c
+++ b/drivers/isdn/hisax/fsm.c
@@ -45,7 +45,7 @@ FsmNew(struct Fsm *fsm, struct FsmNode *fnlist, int fncount)
 void
 FsmFree(struct Fsm *fsm)
 {
-	kfree((void *) fsm->jumpmatrix);
+	kfree(fsm->jumpmatrix);
 }
 
 int
diff --git a/drivers/isdn/mISDN/fsm.c b/drivers/isdn/mISDN/fsm.c
index 26477d4..5ac2dac 100644
--- a/drivers/isdn/mISDN/fsm.c
+++ b/drivers/isdn/mISDN/fsm.c
@@ -51,7 +51,7 @@ EXPORT_SYMBOL(mISDN_FsmNew);
 void
 mISDN_FsmFree(struct Fsm *fsm)
 {
-	kfree((void *) fsm->jumpmatrix);
+	kfree(fsm->jumpmatrix);
 }
 EXPORT_SYMBOL(mISDN_FsmFree);
 
-- 
1.9.1

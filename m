From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Subject: [PATCH 09/18] driver: isdn: hisax: remove cast for kmalloc/kzalloc
 return value
Date: Tue, 12 Mar 2013 13:15:49 +0800
Message-ID: <513EBA05.2040908@cn.fujitsu.com>
References: <513EB23D.7020303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Karsten Keil <isdn@linux-pingi.de>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <513EB23D.7020303@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

remove cast for kmalloc/kzalloc return value.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: netdev@vger.kernel.org
---
 drivers/isdn/hisax/fsm.c    |    2 +-
 drivers/isdn/hisax/hfc_sx.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hisax/fsm.c b/drivers/isdn/hisax/fsm.c
index 1bb2910..c7a9471 100644
--- a/drivers/isdn/hisax/fsm.c
+++ b/drivers/isdn/hisax/fsm.c
@@ -26,7 +26,7 @@ FsmNew(struct Fsm *fsm, struct FsmNode *fnlist, int fncount)
 {
 	int i;
 
-	fsm->jumpmatrix = (FSMFNPTR *)
+	fsm->jumpmatrix =
 		kzalloc(sizeof(FSMFNPTR) * fsm->state_count * fsm->event_count, GFP_KERNEL);
 	if (!fsm->jumpmatrix)
 		return -ENOMEM;
diff --git a/drivers/isdn/hisax/hfc_sx.c b/drivers/isdn/hisax/hfc_sx.c
index 90f34ae..dc4574f 100644
--- a/drivers/isdn/hisax/hfc_sx.c
+++ b/drivers/isdn/hisax/hfc_sx.c
@@ -1479,7 +1479,7 @@ int setup_hfcsx(struct IsdnCard *card)
 			release_region(cs->hw.hfcsx.base, 2);
 			return (0);
 		}
-		if (!(cs->hw.hfcsx.extra = (void *)
+		if (!(cs->hw.hfcsx.extra =
 		      kmalloc(sizeof(struct hfcsx_extra), GFP_ATOMIC))) {
 			release_region(cs->hw.hfcsx.base, 2);
 			printk(KERN_WARNING "HFC-SX: unable to allocate memory\n");
-- 
1.7.1

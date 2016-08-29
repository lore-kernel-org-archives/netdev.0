From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] mISDN: mark symbols static where possible
Date: Mon, 29 Aug 2016 20:14:20 +0800
Message-ID: <1472472860-20336-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: isdn@linux-pingi.de, davem@davemloft.net, an.carpenter@oracle.com,
        mail@maciej.szmigiero.name
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get 1 warning when build kernel with W=1:
drivers/isdn/hardware/mISDN/mISDNipac.c:117:1: warning: no previous prototype for 'isac_empty_fifo' [-Wmissing-prototypes]

In fact, this function is only used in the file in which it is declared
and don't need a declaration, but can be made static.
so this patch marks it 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/isdn/hardware/mISDN/mISDNipac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/mISDN/mISDNipac.c b/drivers/isdn/hardware/mISDN/mISDNipac.c
index aa9b6c3..8d338ba 100644
--- a/drivers/isdn/hardware/mISDN/mISDNipac.c
+++ b/drivers/isdn/hardware/mISDN/mISDNipac.c
@@ -113,7 +113,7 @@ isac_ph_state_bh(struct dchannel *dch)
 	pr_debug("%s: TE newstate %x\n", isac->name, dch->state);
 }
 
-void
+static void
 isac_empty_fifo(struct isac_hw *isac, int count)
 {
 	u8 *ptr;
-- 
2.7.4

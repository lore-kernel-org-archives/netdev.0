From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 1/1] net:nfc: use setup_timer
Date: Thu, 21 Sep 2017 16:29:33 +0530
Message-ID: <1505991573-30298-1-git-send-email-allen.lkml@gmail.com>
Cc: sameo@linux.intel.com, netdev@vger.kernel.org,
        Allen Pais <allen.lkml@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Use setup_timer function instead of initializing timer with the
    function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 net/nfc/core.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/nfc/core.c b/net/nfc/core.c
index 5cf33df..e5e23c2 100644
--- a/net/nfc/core.c
+++ b/net/nfc/core.c
@@ -1094,9 +1094,8 @@ struct nfc_dev *nfc_allocate_device(struct nfc_ops *ops,
 	dev->targets_generation = 1;
 
 	if (ops->check_presence) {
-		init_timer(&dev->check_pres_timer);
-		dev->check_pres_timer.data = (unsigned long)dev;
-		dev->check_pres_timer.function = nfc_check_pres_timeout;
+		setup_timer(&dev->check_pres_timer, nfc_check_pres_timeout,
+			    (unsigned long)dev);
 
 		INIT_WORK(&dev->check_pres_work, nfc_check_pres_work);
 	}
-- 
2.7.4

From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: [PATCH] net: incorrect use of init_completion fixup
Date: Tue, 23 Dec 2014 18:47:50 +0100
Message-ID: <1419356870-22710-1-git-send-email-der.herr@hofr.at>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <der.herr@hofr.at>
To: Rasesh Mody <rasesh.mody@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The second init_completion call should be a reinit_completion here.

patch is against 3.18.0 linux-next

Signed-off-by: Nicholas Mc Guire <der.herr@hofr.at>
---
 drivers/net/ethernet/brocade/bna/bnad_debugfs.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad_debugfs.c b/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
index 7d6aa8c..619083a 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
@@ -172,7 +172,7 @@ bnad_get_debug_drvinfo(struct bnad *bnad, void *buffer, u32 len)

 	/* Retrieve flash partition info */
 	fcomp.comp_status = 0;
-	init_completion(&fcomp.comp);
+	reinit_completion(&fcomp.comp);
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	ret = bfa_nw_flash_get_attr(&bnad->bna.flash, &drvinfo->flash_attr,
 				bnad_cb_completion, &fcomp);
--
1.7.10.4

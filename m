From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next 2/3] bna: change type of bna_id to atomic_t
Date: Fri, 29 Jul 2016 19:52:57 +0200
Message-ID: <1469814778-23186-3-git-send-email-ivecera@redhat.com>
References: <1469814778-23186-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40762 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753301AbcG2RxD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2016 13:53:03 -0400
In-Reply-To: <1469814778-23186-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change type of bna_id to atomic_t. The bnad_list_mutex is used to prevent
a race when bna_id is incremented. After the change the mutex can be
removed in the next step.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 696bbae..2bed050 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -54,7 +54,7 @@ MODULE_PARM_DESC(bna_debugfs_enable, "Enables debugfs feature, default=1,"
  * Global variables
  */
 static u32 bnad_rxqs_per_cq = 2;
-static u32 bna_id;
+static atomic_t bna_id;
 static struct mutex bnad_list_mutex;
 static const u8 bnad_bcast_addr[] __aligned(2) =
 	{ 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
@@ -79,7 +79,6 @@ static void
 bnad_add_to_list(struct bnad *bnad)
 {
 	mutex_lock(&bnad_list_mutex);
-	bnad->id = bna_id++;
 	mutex_unlock(&bnad_list_mutex);
 }
 
@@ -3651,6 +3650,7 @@ bnad_pci_probe(struct pci_dev *pdev,
 	bnad = netdev_priv(netdev);
 	bnad_lock_init(bnad);
 	bnad_add_to_list(bnad);
+	bnad->id = atomic_inc_return(&bna_id) - 1;
 
 	mutex_lock(&bnad->conf_mutex);
 	/*
-- 
2.7.3

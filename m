From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next 1/3] bna: remove useless linked list
Date: Fri, 29 Jul 2016 19:52:56 +0200
Message-ID: <1469814778-23186-2-git-send-email-ivecera@redhat.com>
References: <1469814778-23186-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57750 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753230AbcG2RxC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2016 13:53:02 -0400
In-Reply-To: <1469814778-23186-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove global variable bnad_list and bnad->list_entry that are used
as list of bna driver instances. It is not necessary and useless.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 3 ---
 drivers/net/ethernet/brocade/bna/bnad.h | 1 -
 2 files changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 771cc26..696bbae 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -56,7 +56,6 @@ MODULE_PARM_DESC(bna_debugfs_enable, "Enables debugfs feature, default=1,"
 static u32 bnad_rxqs_per_cq = 2;
 static u32 bna_id;
 static struct mutex bnad_list_mutex;
-static LIST_HEAD(bnad_list);
 static const u8 bnad_bcast_addr[] __aligned(2) =
 	{ 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
 
@@ -80,7 +79,6 @@ static void
 bnad_add_to_list(struct bnad *bnad)
 {
 	mutex_lock(&bnad_list_mutex);
-	list_add_tail(&bnad->list_entry, &bnad_list);
 	bnad->id = bna_id++;
 	mutex_unlock(&bnad_list_mutex);
 }
@@ -89,7 +87,6 @@ static void
 bnad_remove_from_list(struct bnad *bnad)
 {
 	mutex_lock(&bnad_list_mutex);
-	list_del(&bnad->list_entry);
 	mutex_unlock(&bnad_list_mutex);
 }
 
diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index f4ed816..46f7b84 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -288,7 +288,6 @@ struct bnad_rx_unmap_q {
 struct bnad {
 	struct net_device	*netdev;
 	u32			id;
-	struct list_head	list_entry;
 
 	/* Data path */
 	struct bnad_tx_info tx_info[BNAD_MAX_TX];
-- 
2.7.3

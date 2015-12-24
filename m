From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Get TID calculation right for IPv6 mode
Date: Thu, 24 Dec 2015 16:15:17 +0530
Message-ID: <1450953917-30876-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:8397 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932217AbbLXKnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 05:43:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CLIP is always enabled and hardware uses 2 TID entries instead of 4 for
IPv6 in CLIP mode.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index c0dd533..bfe50aa 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1506,7 +1506,7 @@ int cxgb4_alloc_stid(struct tid_info *t, int family, void *data)
 		else
 			stid = -1;
 	} else {
-		stid = bitmap_find_free_region(t->stid_bmap, t->nstids, 2);
+		stid = bitmap_find_free_region(t->stid_bmap, t->nstids, 1);
 		if (stid < 0)
 			stid = -1;
 	}
@@ -1520,7 +1520,7 @@ int cxgb4_alloc_stid(struct tid_info *t, int family, void *data)
 		if (family == PF_INET)
 			t->stids_in_use++;
 		else
-			t->stids_in_use += 4;
+			t->stids_in_use += 2;
 	}
 	spin_unlock_bh(&t->stid_lock);
 	return stid;
@@ -1571,13 +1571,13 @@ void cxgb4_free_stid(struct tid_info *t, unsigned int stid, int family)
 	if (family == PF_INET)
 		__clear_bit(stid, t->stid_bmap);
 	else
-		bitmap_release_region(t->stid_bmap, stid, 2);
+		bitmap_release_region(t->stid_bmap, stid, 1);
 	t->stid_tab[stid].data = NULL;
 	if (stid < t->nstids) {
 		if (family == PF_INET)
 			t->stids_in_use--;
 		else
-			t->stids_in_use -= 4;
+			t->stids_in_use -= 2;
 	} else {
 		t->sftids_in_use--;
 	}
-- 
2.3.4

From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 2/4] net: cpsw: remove two unused global functions
Date: Mon, 25 May 2015 11:02:14 +0200
Message-ID: <3a714303a320381c442bccaa62188b54cfd706c6.1432544195.git.richardcochran@gmail.com>
References: <cover.1432544195.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36794 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752081AbbEYJCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 05:02:25 -0400
Received: by wizk4 with SMTP id k4so41967333wiz.1
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 02:02:24 -0700 (PDT)
In-Reply-To: <cover.1432544195.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The funtions, cpsw_ale_flush and cpsw_ale_set_ageout, have never been used
since they were first introduced.  This patch removes the dead code.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/cpsw_ale.c | 45 --------------------------------------
 drivers/net/ethernet/ti/cpsw_ale.h |  2 --
 2 files changed, 47 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw_ale.c b/drivers/net/ethernet/ti/cpsw_ale.c
index 6e927b4..43b061b 100644
--- a/drivers/net/ethernet/ti/cpsw_ale.c
+++ b/drivers/net/ethernet/ti/cpsw_ale.c
@@ -268,39 +268,6 @@ int cpsw_ale_flush_multicast(struct cpsw_ale *ale, int port_mask, int vid)
 }
 EXPORT_SYMBOL_GPL(cpsw_ale_flush_multicast);
 
-static void cpsw_ale_flush_ucast(struct cpsw_ale *ale, u32 *ale_entry,
-				 int port_mask)
-{
-	int port;
-
-	port = cpsw_ale_get_port_num(ale_entry);
-	if ((BIT(port) & port_mask) == 0)
-		return; /* ports dont intersect, not interested */
-	cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_FREE);
-}
-
-int cpsw_ale_flush(struct cpsw_ale *ale, int port_mask)
-{
-	u32 ale_entry[ALE_ENTRY_WORDS];
-	int ret, idx;
-
-	for (idx = 0; idx < ale->params.ale_entries; idx++) {
-		cpsw_ale_read(ale, idx, ale_entry);
-		ret = cpsw_ale_get_entry_type(ale_entry);
-		if (ret != ALE_TYPE_ADDR && ret != ALE_TYPE_VLAN_ADDR)
-			continue;
-
-		if (cpsw_ale_get_mcast(ale_entry))
-			cpsw_ale_flush_mcast(ale, ale_entry, port_mask);
-		else
-			cpsw_ale_flush_ucast(ale, ale_entry, port_mask);
-
-		cpsw_ale_write(ale, idx, ale_entry);
-	}
-	return 0;
-}
-EXPORT_SYMBOL_GPL(cpsw_ale_flush);
-
 static inline void cpsw_ale_set_vlan_entry_type(u32 *ale_entry,
 						int flags, u16 vid)
 {
@@ -752,18 +719,6 @@ static void cpsw_ale_timer(unsigned long arg)
 	}
 }
 
-int cpsw_ale_set_ageout(struct cpsw_ale *ale, int ageout)
-{
-	del_timer_sync(&ale->timer);
-	ale->ageout = ageout * HZ;
-	if (ale->ageout) {
-		ale->timer.expires = jiffies + ale->ageout;
-		add_timer(&ale->timer);
-	}
-	return 0;
-}
-EXPORT_SYMBOL_GPL(cpsw_ale_set_ageout);
-
 void cpsw_ale_start(struct cpsw_ale *ale)
 {
 	u32 rev;
diff --git a/drivers/net/ethernet/ti/cpsw_ale.h b/drivers/net/ethernet/ti/cpsw_ale.h
index af1e7ec..a700189 100644
--- a/drivers/net/ethernet/ti/cpsw_ale.h
+++ b/drivers/net/ethernet/ti/cpsw_ale.h
@@ -90,8 +90,6 @@ int cpsw_ale_destroy(struct cpsw_ale *ale);
 void cpsw_ale_start(struct cpsw_ale *ale);
 void cpsw_ale_stop(struct cpsw_ale *ale);
 
-int cpsw_ale_set_ageout(struct cpsw_ale *ale, int ageout);
-int cpsw_ale_flush(struct cpsw_ale *ale, int port_mask);
 int cpsw_ale_flush_multicast(struct cpsw_ale *ale, int port_mask, int vid);
 int cpsw_ale_add_ucast(struct cpsw_ale *ale, u8 *addr, int port,
 		       int flags, u16 vid);
-- 
2.1.4

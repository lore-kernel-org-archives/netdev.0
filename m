From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net 2/2] bnx2x: fix dump flag handling
Date: Mon,  1 Jul 2013 17:23:06 +0200
Message-ID: <1372692186-31032-3-git-send-email-mschmidt@redhat.com>
References: <1372692186-31032-1-git-send-email-mschmidt@redhat.com>
Cc: netdev@vger.kernel.org, Miriam Shitrit <miris@broadcom.com>,
	Yuval Mintz <yuvalmin@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24577 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752807Ab3GAPXQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jul 2013 11:23:16 -0400
In-Reply-To: <1372692186-31032-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x interprets the dump flag as an index of a register preset.
It is important to validate the index to avoid out of bounds
memory accesses.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 3 +++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c    | 2 ++
 2 files changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 61ccae5..10b52b0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -960,6 +960,9 @@ static int bnx2x_set_dump(struct net_device *dev, struct ethtool_dump *val)
 	struct bnx2x *bp = netdev_priv(dev);
 
 	/* Use the ethtool_dump "flag" field as the dump preset index */
+	if (val->flag < 1 || val->flag > DUMP_MAX_PRESETS)
+		return -EINVAL;
+
 	bp->dump_preset_idx = val->flag;
 	return 0;
 }
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index b4c9dea..2a9927f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11497,6 +11497,8 @@ static int bnx2x_init_bp(struct bnx2x *bp)
 		bp->min_msix_vec_cnt = 2;
 	BNX2X_DEV_INFO("bp->min_msix_vec_cnt %d", bp->min_msix_vec_cnt);
 
+	bp->dump_preset_idx = 1;
+
 	return rc;
 }
 
-- 
1.8.1.4

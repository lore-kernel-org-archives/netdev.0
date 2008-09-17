From: "Benjamin Li" <benli@broadcom.com>
Subject: [NET-NEXT PATCH] bnx2: Remove name field from bnx2 structure
Date: Wed, 17 Sep 2008 16:02:20 -0700
Message-ID: <2facac5d8110b82264e3c976afd5c5013c41dada.1219454143.git.benli@broadcom.com>
References: <cover.1219454143.git.benli@broadcom.com>
 <a93511dbe76cb994f3dbd16c3ad820617d4187e9.1219454143.git.benli@broadcom.com>
 <e5dd28099c48ea622c1ec67bce736dba9a139a20.1219454143.git.benli@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: benli@broadcom.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2969 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755066AbYIQXCb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Sep 2008 19:02:31 -0400
Received: from mail-irva-8.broadcom.com (mail-irva-8 [10.11.18.52]) by
 mail-irva-10.broadcom.com (Postfix) with ESMTP id B2E122B0 for
 <netdev@vger.kernel.org>; Wed, 17 Sep 2008 16:02:25 -0700 (PDT)
In-Reply-To: <e5dd28099c48ea622c1ec67bce736dba9a139a20.1219454143.git.benli@broadcom.com>
In-Reply-To: <cover.1219454143.git.benli@broadcom.com>
References: <cover.1219454143.git.benli@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The name of the board is only used during the initialization of
the adapter.  We can save the space of a pointer by not storing
this information.

Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    3 +--
 drivers/net/bnx2.h |    2 --
 2 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index a78b664..8417766 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7718,7 +7718,6 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	memcpy(dev->dev_addr, bp->mac_addr, 6);
 	memcpy(dev->perm_addr, bp->mac_addr, 6);
-	bp->name = board_info[ent->driver_data].name;
 
 	dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 	if (CHIP_NUM(bp) == CHIP_NUM_5709)
@@ -7745,7 +7744,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	printk(KERN_INFO "%s: %s (%c%d) %s found at mem %lx, "
 		"IRQ %d, node addr %s\n",
 		dev->name,
-		bp->name,
+		board_info[ent->driver_data].name,
 		((CHIP_ID(bp) & 0xf000) >> 12) + 'A',
 		((CHIP_ID(bp) & 0x0ff0) >> 4),
 		bnx2_bus_string(bp, str),
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index c3c579f..cb47c98 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6701,8 +6701,6 @@ struct bnx2 {
 
 	/* End of fields used in the performance code paths. */
 
-	char			*name;
-
 	int			timer_interval;
 	int			current_interval;
 	struct			timer_list timer;
-- 
1.5.6.4



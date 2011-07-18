From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 20/45] bna: MBOX IRQ Sync Vector Num Fix
Date: Mon, 18 Jul 2011 01:22:40 -0700
Message-ID: <1310977385-5268-10-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:48232 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753418Ab1GRIX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:23:56 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Fixed the vector number used for syncing MBox IRQ

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bnad.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index cd2b921..076f398 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -2180,7 +2180,7 @@ bnad_mbox_irq_sync(struct bnad *bnad)
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	if (bnad->cfg_flags & BNAD_CF_MSIX)
-		irq = bnad->msix_table[bnad->msix_num - 1].vector;
+		irq = bnad->msix_table[BNAD_MAILBOX_MSIX_INDEX].vector;
 	else
 		irq = bnad->pcidev->irq;
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
-- 
1.7.1


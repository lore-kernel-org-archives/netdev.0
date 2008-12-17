From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 1/2] bnx2: Rename MSI-X vectors.
Date: Tue, 16 Dec 2008 18:18:34 -0800
Message-ID: <1229480315-16912-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1775 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752214AbYLQCLW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2008 21:11:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change MSI-X vector names to "ethx-%d".

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |    4 +++-
 drivers/net/bnx2.h |    2 +-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 0e2218d..6ba2fec 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -5827,6 +5827,8 @@ bnx2_enable_msix(struct bnx2 *bp, int msix_vecs)
 {
 	int i, rc;
 	struct msix_entry msix_ent[BNX2_MAX_MSIX_VEC];
+	struct net_device *dev = bp->dev;
+	const int len = sizeof(bp->irq_tbl[0].name);
 
 	bnx2_setup_msix_tbl(bp);
 	REG_WR(bp, BNX2_PCI_MSIX_CONTROL, BNX2_MAX_MSIX_HW_VEC - 1);
@@ -5837,7 +5839,7 @@ bnx2_enable_msix(struct bnx2 *bp, int msix_vecs)
 		msix_ent[i].entry = i;
 		msix_ent[i].vector = 0;
 
-		strcpy(bp->irq_tbl[i].name, bp->dev->name);
+		snprintf(bp->irq_tbl[i].name, len, "%s-%d", dev->name, i);
 		bp->irq_tbl[i].handler = bnx2_msi_1shot;
 	}
 
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 2f43c45..88f962b 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6627,7 +6627,7 @@ struct bnx2_irq {
 	irq_handler_t	handler;
 	unsigned int	vector;
 	u8		requested;
-	char		name[16];
+	char		name[IFNAMSIZ + 2];
 };
 
 struct bnx2_tx_ring_info {
-- 
1.5.6.GIT



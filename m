From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 2/3] bnxt_en: Log a message, if enabling NTUPLE filtering fails.
Date: Mon, 25 Jul 2016 12:33:36 -0400
Message-ID: <1469464417-786-3-git-send-email-michael.chan@broadcom.com>
References: <1469464417-786-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:32832 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752941AbcGYQd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 12:33:56 -0400
Received: by mail-pa0-f45.google.com with SMTP id ks6so62926100pab.0
        for <netdev@vger.kernel.org>; Mon, 25 Jul 2016 09:33:56 -0700 (PDT)
In-Reply-To: <1469464417-786-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara-v.volam@broadcom.com>

If there are not enough resources to enable ntuple filtering,
log a warning message.

v2: Use single message and add missing newline.

Signed-off-by: Vasundhara Volam <vasundhara-v.volam@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 7de7d7a..eac0f2b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5790,8 +5790,12 @@ static bool bnxt_rfs_capable(struct bnxt *bp)
 		return false;
 
 	vnics = 1 + bp->rx_nr_rings;
-	if (vnics > pf->max_rsscos_ctxs || vnics > pf->max_vnics)
+	if (vnics > pf->max_rsscos_ctxs || vnics > pf->max_vnics) {
+		netdev_warn(bp->dev,
+			    "Not enough resources to support NTUPLE filters, enough resources for up to %d rx rings\n",
+			    min(pf->max_rsscos_ctxs - 1, pf->max_vnics - 1));
 		return false;
+	}
 
 	return true;
 #else
@@ -5804,7 +5808,7 @@ static netdev_features_t bnxt_fix_features(struct net_device *dev,
 {
 	struct bnxt *bp = netdev_priv(dev);
 
-	if (!bnxt_rfs_capable(bp))
+	if ((features & NETIF_F_NTUPLE) && !bnxt_rfs_capable(bp))
 		features &= ~NETIF_F_NTUPLE;
 
 	/* Both CTAG and STAG VLAN accelaration on the RX side have to be
-- 
1.8.3.1

From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 3/3] bnxt_en: fix switchdev port naming for external-port-rep and vf-reps
Date: Tue, 25 Jul 2017 13:28:41 -0400
Message-ID: <1501003721-12407-4-git-send-email-michael.chan@broadcom.com>
References: <1501003721-12407-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, Sathya Perla <sathya.perla@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:37525 "EHLO
        mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751607AbdGYR27 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 13:28:59 -0400
Received: by mail-qk0-f171.google.com with SMTP id q130so32025083qka.4
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 10:28:59 -0700 (PDT)
In-Reply-To: <1501003721-12407-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@broadcom.com>

Fix the phys_port_name for the external physical port to be in
"pA" format and that of VF-rep to be in "pCvfD" format as
suggested by Jakub Kicinski.

Fixes: c124a62ff2dd ("bnxt_en: add support for port_attr_get and get_phys_port_name")
Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c     | 6 +-----
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c | 4 +++-
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index badbc35..4b32cf0 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7556,11 +7556,7 @@ static int bnxt_get_phys_port_name(struct net_device *dev, char *buf,
 	if (!BNXT_PF(bp))
 		return -EOPNOTSUPP;
 
-	/* The switch-id that the pf belongs to is exported by
-	 * the switchdev ndo. This name is just to distinguish from the
-	 * vf-rep ports.
-	 */
-	rc = snprintf(buf, len, "pf%d", bp->pf.port_id);
+	rc = snprintf(buf, len, "p%d", bp->pf.port_id);
 
 	if (rc >= len)
 		return -EOPNOTSUPP;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
index c00352a..b05c5d0 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
@@ -141,9 +141,11 @@ static int bnxt_vf_rep_get_phys_port_name(struct net_device *dev, char *buf,
 					  size_t len)
 {
 	struct bnxt_vf_rep *vf_rep = netdev_priv(dev);
+	struct pci_dev *pf_pdev = vf_rep->bp->pdev;
 	int rc;
 
-	rc = snprintf(buf, len, "vfr%d", vf_rep->vf_idx);
+	rc = snprintf(buf, len, "pf%dvf%d", PCI_FUNC(pf_pdev->devfn),
+		      vf_rep->vf_idx);
 	if (rc >= len)
 		return -EOPNOTSUPP;
 	return 0;
-- 
1.8.3.1

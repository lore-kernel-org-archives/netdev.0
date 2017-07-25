From: Sathya Perla <sathya.perla@broadcom.com>
Subject: [PATCH net-next 3/3] bnxt_en: fix switchdev port naming for external-port-rep and vf-reps
Date: Tue, 25 Jul 2017 06:49:33 -0400
Message-ID: <20170725104933.9633-3-sathya.perla@broadcom.com>
References: <20170725104933.9633-1-sathya.perla@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lpdvsmtp02.broadcom.com ([192.19.232.149]:44492 "EHLO
        relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751636AbdGYKzd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 06:55:33 -0400
Received: from Sathya-S84.localdomain (unknown [10.192.238.84])
        by relay.smtp.broadcom.com (Postfix) with ESMTP id 523501A002C
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 03:49:38 -0700 (PDT)
In-Reply-To: <20170725104933.9633-1-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the phys_port_name for the external physical port to be in
"pA" format and that of VF-rep to be in "pCvfD" format as
suggested by Jakub Kicinski.

Fixes: c124a62ff2dd ("bnxt_en: add support for port_attr_get and get_phys_port_name")
Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
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
index 9ba505f..9419590 100644
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

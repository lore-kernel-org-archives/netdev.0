From: Michal Kalderon <michals@broadcom.com>
Subject: [PATCH net] bnx2x: avoid null pointer dereference when enabling SR-IOV
Date: Wed, 4 Dec 2013 12:04:54 +0200
Message-ID: <1386151494-28876-1-git-send-email-michals@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michal Kalderon <michals@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:7701 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755297Ab3LDKOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 05:14:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed NULL pointer dereference when dynamically activating SR-IOV after vf
database failed to be allocated in probe stage (for example due to no ARI
support in pci hub).

Signed-off-by: Michal Kalderon <michals@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 0216d59..2e46c28 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -3114,6 +3114,11 @@ int bnx2x_sriov_configure(struct pci_dev *dev, int num_vfs_param)
 {
 	struct bnx2x *bp = netdev_priv(pci_get_drvdata(dev));
 
+	if (!IS_SRIOV(bp)) {
+		BNX2X_ERR("failed to configure SR-IOV since vfdb was not allocated. Check dmesg for errors in probe stage\n");
+		return -EINVAL;
+	}
+
 	DP(BNX2X_MSG_IOV, "bnx2x_sriov_configure called with %d, BNX2X_NR_VIRTFN(bp) was %d\n",
 	   num_vfs_param, BNX2X_NR_VIRTFN(bp));
 
-- 
1.8.5.rc3

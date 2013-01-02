From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH net-next] bnx2x: Fix compilation when CONFIG_PCI_IOV is
 not defined
Date: Wed, 2 Jan 2013 15:36:25 +0200
Message-ID: <1357133785-9569-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, eilong@broadcom.com,
	"Ariel Elior" <ariele@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2738 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752682Ab3ABNd3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jan 2013 08:33:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch ifdefs out the use of PCI_IOV_RESOURCES which exists in the
kernel only when CONFIG_PCI_IOV is defined. There is no point in doing
the same for the invocation of SRIOV functionality in the driver as it
will be immediately failed by a kernel which was thus compiled.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 71fcef0..2142839 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -1792,6 +1792,7 @@ static int bnx2x_vf_devfn(struct bnx2x *bp, int vfid)
 
 static void bnx2x_vf_set_bars(struct bnx2x *bp, struct bnx2x_virtf *vf)
 {
+#ifdef CONFIG_PCI_IOV
 	int i, n;
 	struct pci_dev *dev = bp->pdev;
 	struct bnx2x_sriov *iov = &bp->vfdb->sriov;
@@ -1804,6 +1805,7 @@ static void bnx2x_vf_set_bars(struct bnx2x *bp, struct bnx2x_virtf *vf)
 		vf->bars[n].bar = start + size * vf->abs_vfid;
 		vf->bars[n].size = size;
 	}
+#endif /* CONFIG_PCI_IOV */
 }
 
 static int bnx2x_ari_enabled(struct pci_dev *dev)
-- 
1.7.9.GIT

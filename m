From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next] bnx2x: Fix compilation when CONFIG_BNX2X_SRIOV is not set
Date: Wed, 26 Mar 2014 09:06:29 +0200
Message-ID: <1395817589-22890-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:27730 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751291AbaCZHHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 03:07:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 370d4a26 "bnx2x: Create workqueue for IOV related tasks" breaks bnx2x
compilation when CONFIG_BNX2X_SRIOV is not set - "multiple definition of
`bnx2x_schedule_iov_task'".

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
Hi Dave,

Please accept this to net-next as it fixes our latest submission there.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
index db73a24..8bf7645 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
@@ -574,7 +574,7 @@ static inline int bnx2x_sriov_configure(struct pci_dev *dev, int num_vfs) {retur
 static inline void bnx2x_iov_channel_down(struct bnx2x *bp) {}
 
 static inline void bnx2x_iov_task(struct work_struct *work) {}
-void bnx2x_schedule_iov_task(struct bnx2x *bp, enum bnx2x_iov_flag flag) {}
+static inline void bnx2x_schedule_iov_task(struct bnx2x *bp, enum bnx2x_iov_flag flag) {}
 
 #endif /* CONFIG_BNX2X_SRIOV */
 #endif /* bnx2x_sriov.h */
-- 
1.8.1.4

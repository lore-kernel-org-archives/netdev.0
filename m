From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 02/12] qlcnic: Disable INT-x interrupt for 83xx on driver unload
Date: Fri, 24 May 2013 03:04:26 -0400
Message-ID: <1369379076-4718-3-git-send-email-shahed.shaikh@qlogic.com>
References: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe001.messaging.microsoft.com ([207.46.163.24]:39052
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759561Ab3EXH3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 03:29:47 -0400
In-Reply-To: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

o Set HW mask for 8300 Series adapter, in INT-x mode, to
  stop generating interrupt during driver unload.

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index b4ff1e3..9b91d6a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -312,6 +312,11 @@ inline void qlcnic_83xx_clear_legacy_intr_mask(struct qlcnic_adapter *adapter)
 	writel(0, adapter->tgt_mask_reg);
 }
 
+inline void qlcnic_83xx_set_legacy_intr_mask(struct qlcnic_adapter *adapter)
+{
+	writel(1, adapter->tgt_mask_reg);
+}
+
 /* Enable MSI-x and INT-x interrupts */
 void qlcnic_83xx_enable_intr(struct qlcnic_adapter *adapter,
 			     struct qlcnic_host_sds_ring *sds_ring)
@@ -458,6 +463,9 @@ void qlcnic_83xx_free_mbx_intr(struct qlcnic_adapter *adapter)
 {
 	u32 num_msix;
 
+	if (!(adapter->flags & QLCNIC_MSIX_ENABLED))
+		qlcnic_83xx_set_legacy_intr_mask(adapter);
+
 	qlcnic_83xx_disable_mbx_intr(adapter);
 
 	if (adapter->flags & QLCNIC_MSIX_ENABLED)
-- 
1.5.6

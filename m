From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH net 3/9] qlcnic: Fix NULL pointer dereference in VF probe path.
Date: Fri, 19 Jul 2013 16:56:28 -0400
Message-ID: <1374267394-27697-4-git-send-email-sucheta.chakraborty@qlogic.com>
References: <1374267394-27697-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0252.outbound.messaging.microsoft.com ([213.199.154.252]:45537
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751838Ab3GSVYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 17:24:05 -0400
In-Reply-To: <1374267394-27697-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Check for non-NULL set_mac_filter_count function pointer
  before calling it fixes the panic.

This patch fixes regression introduced by patch
"qlcnic: Secondary unicast MAC address support." with
commit id 168e4fb54c11865668ad50eff81b5f2729e0e0f4.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index b00cf56..f4bb8f5 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1869,7 +1869,8 @@ static inline void qlcnic_free_mac_list(struct qlcnic_adapter *adapter)
 
 static inline void qlcnic_set_mac_filter_count(struct qlcnic_adapter *adapter)
 {
-	adapter->ahw->hw_ops->set_mac_filter_count(adapter);
+	if (adapter->ahw->hw_ops->set_mac_filter_count)
+		adapter->ahw->hw_ops->set_mac_filter_count(adapter);
 }
 
 static inline void qlcnic_dev_request_reset(struct qlcnic_adapter *adapter,
-- 
1.7.1

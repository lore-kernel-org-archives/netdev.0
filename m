From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 7/8] qlcnic: Enable IPv6 LRO even if IP address is not programmed
Date: Fri, 10 Jan 2014 11:48:58 -0500
Message-ID: <1389372539-13753-8-git-send-email-shahed.shaikh@qlogic.com>
References: <1389372539-13753-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:53999 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753146AbaAJRXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 12:23:47 -0500
In-Reply-To: <1389372539-13753-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

o Enabling BIT_9 while configuring hardware LRO allows adapter to
  perform LRO even if destination IP address is not programmed in adapter.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index e96b76d..6ca5e57 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -782,8 +782,8 @@ void qlcnic_82xx_config_intr_coalesce(struct qlcnic_adapter *adapter)
 			"Could not send interrupt coalescing parameters\n");
 }
 
-#define QLCNIC_ENABLE_IPV4_LRO		1
-#define QLCNIC_ENABLE_IPV6_LRO		2
+#define QLCNIC_ENABLE_IPV4_LRO		BIT_0
+#define QLCNIC_ENABLE_IPV6_LRO		(BIT_1 | BIT_9)
 
 int qlcnic_82xx_config_hw_lro(struct qlcnic_adapter *adapter, int enable)
 {
-- 
1.8.3.1

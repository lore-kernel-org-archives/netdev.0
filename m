From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 1/2] qlcnic: Do not force adapter to perform LRO without destination IP check
Date: Fri, 25 Oct 2013 10:38:36 -0400
Message-ID: <1382711917-28501-2-git-send-email-shahed.shaikh@qlogic.com>
References: <1382711917-28501-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:18986 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754918Ab3JYPJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 11:09:36 -0400
In-Reply-To: <1382711917-28501-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Forcing adapter to perform LRO without destination IP check
degrades the performance.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index f8adc7b..b64e2be 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -785,8 +785,6 @@ void qlcnic_82xx_config_intr_coalesce(struct qlcnic_adapter *adapter)
 
 #define QLCNIC_ENABLE_IPV4_LRO		1
 #define QLCNIC_ENABLE_IPV6_LRO		2
-#define QLCNIC_NO_DEST_IPV4_CHECK	(1 << 8)
-#define QLCNIC_NO_DEST_IPV6_CHECK	(2 << 8)
 
 int qlcnic_82xx_config_hw_lro(struct qlcnic_adapter *adapter, int enable)
 {
@@ -806,11 +804,10 @@ int qlcnic_82xx_config_hw_lro(struct qlcnic_adapter *adapter, int enable)
 
 	word = 0;
 	if (enable) {
-		word = QLCNIC_ENABLE_IPV4_LRO | QLCNIC_NO_DEST_IPV4_CHECK;
+		word = QLCNIC_ENABLE_IPV4_LRO;
 		if (adapter->ahw->extra_capability[0] &
 		    QLCNIC_FW_CAP2_HW_LRO_IPV6)
-			word |= QLCNIC_ENABLE_IPV6_LRO |
-				QLCNIC_NO_DEST_IPV6_CHECK;
+			word |= QLCNIC_ENABLE_IPV6_LRO;
 	}
 
 	req.words[0] = cpu_to_le64(word);
-- 
1.8.1.4

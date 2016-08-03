From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net 2/3] qlcnic: fix napi budget alteration
Date: Wed, 3 Aug 2016 04:02:03 -0400
Message-ID: <1470211324-23430-3-git-send-email-manish.chopra@qlogic.com>
References: <1470211324-23430-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:38817 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757241AbcHCIot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 04:44:49 -0400
In-Reply-To: <1470211324-23430-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver modifies the supplied NAPI budget in qlcnic_83xx_msix_tx_poll()
function. Instead, it should use the budget as it is.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 87c642d..fedd736 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -102,7 +102,6 @@
 #define QLCNIC_RESPONSE_DESC	0x05
 #define QLCNIC_LRO_DESC  	0x12
 
-#define QLCNIC_TX_POLL_BUDGET		128
 #define QLCNIC_TCP_HDR_SIZE		20
 #define QLCNIC_TCP_TS_OPTION_SIZE	12
 #define QLCNIC_FETCH_RING_ID(handle)	((handle) >> 63)
@@ -2008,7 +2007,6 @@ static int qlcnic_83xx_msix_tx_poll(struct napi_struct *napi, int budget)
 	struct qlcnic_host_tx_ring *tx_ring;
 	struct qlcnic_adapter *adapter;
 
-	budget = QLCNIC_TX_POLL_BUDGET;
 	tx_ring = container_of(napi, struct qlcnic_host_tx_ring, napi);
 	adapter = tx_ring->adapter;
 	work_done = qlcnic_process_cmd_ring(adapter, tx_ring, budget);
-- 
1.5.6

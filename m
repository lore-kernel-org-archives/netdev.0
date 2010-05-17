From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 5/7] qlcnic: fix internal loopback test
Date: Mon, 17 May 2010 04:22:12 -0700
Message-ID: <1274095334-32362-6-git-send-email-amit.salecha@qlogic.com>
References: <1274095334-32362-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:49040 "EHLO
	dut4145.unminc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752021Ab0EQKVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 06:21:51 -0400
In-Reply-To: <1274095334-32362-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Reset/set DEV_UP bit during allocation and deallocation of resources.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index b076474..dde1e8a 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -870,6 +870,7 @@ void qlcnic_diag_free_res(struct net_device *netdev, int max_sds_rings)
 	struct qlcnic_host_sds_ring *sds_ring;
 	int ring;
 
+	clear_bit(__QLCNIC_DEV_UP, &adapter->state);
 	if (adapter->diag_test == QLCNIC_INTERRUPT_TEST) {
 		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 			sds_ring = &adapter->recv_ctx.sds_rings[ring];
@@ -920,6 +921,7 @@ int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
 			qlcnic_enable_int(sds_ring);
 		}
 	}
+	set_bit(__QLCNIC_DEV_UP, &adapter->state);
 
 	return 0;
 }
-- 
1.5.6.1


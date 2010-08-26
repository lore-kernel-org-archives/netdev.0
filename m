From: leitao@linux.vnet.ibm.com
Subject: [PATCH] qlge: reset the chip before freeing the buffers
Date: Thu, 26 Aug 2010 15:27:58 -0300
Message-ID: <1282847278-23416-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, ying.lok@qlogic.com,
	Breno Leitao <leitao@linux.vnet.ibm.com>
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:35482 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752774Ab0HZS2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 14:28:05 -0400
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp04.br.ibm.com (8.14.4/8.13.1) with ESMTP id o7QIOCHE010637
	for <netdev@vger.kernel.org>; Thu, 26 Aug 2010 15:24:12 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7QIRbPS2388158
	for <netdev@vger.kernel.org>; Thu, 26 Aug 2010 15:27:37 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7QIRlgX032615
	for <netdev@vger.kernel.org>; Thu, 26 Aug 2010 15:27:47 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Qlge is freeing the buffers before stopping the card DMA, and
this can cause some severe error, as a EEH event on PPC.

This patch just stop the card and then free the resources.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/qlge/qlge_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 5a24521..2e0ca39 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3926,12 +3926,12 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 	for (i = 0; i < qdev->rss_ring_count; i++)
 		netif_napi_del(&qdev->rx_ring[i].napi);
 
-	ql_free_rx_buffers(qdev);
-
 	status = ql_adapter_reset(qdev);
 	if (status)
 		netif_err(qdev, ifdown, qdev->ndev, "reset(func #%d) FAILED!\n",
 			  qdev->func);
+	ql_free_rx_buffers(qdev);
+
 	return status;
 }
 
-- 
1.6.5.2


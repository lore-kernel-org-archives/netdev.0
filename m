From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 2/7] qlge: Fix frame routing issue related to bonding.
Date: Thu,  8 Oct 2009 12:54:38 -0700
Message-ID: <1255031683-3912-3-git-send-email-ron.mercer@qlogic.com>
References: <1255031683-3912-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:40572 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933125AbZJHUBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 16:01:46 -0400
In-Reply-To: <1255031683-3912-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently frames are routed based on their type and MAC address. This
patch adds the port number on which the frame arrived to the routing.
This prevents problems in the case where both interfaces have the same MAC address in
a routing configuration.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 04fc711..d66ad8d 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3241,6 +3241,13 @@ static int ql_adapter_initialize(struct ql_adapter *qdev)
 	ql_write32(qdev, SPLT_HDR, SPLT_HDR_EP |
 		min(SMALL_BUFFER_SIZE, MAX_SPLIT_SIZE));
 
+	/* Set RX packet routing to use port/pci function on which the
+	 * packet arrived on in addition to usual frame routing.
+	 * This is helpful on bonding where both interfaces can have
+	 * the same MAC address.
+	 */
+	ql_write32(qdev, RST_FO, RST_FO_RR_MASK | RST_FO_RR_RCV_FUNC_CQ);
+
 	/* Start up the rx queues. */
 	for (i = 0; i < qdev->rx_ring_count; i++) {
 		status = ql_start_rx_ring(qdev, &qdev->rx_ring[i]);
-- 
1.6.0.2


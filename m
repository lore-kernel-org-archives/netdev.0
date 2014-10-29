From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 2/3] sunvnet: Reset LDC_EVENT_DATA_READY when napi
 completes.
Date: Wed, 29 Oct 2014 15:27:37 -0400
Message-ID: <20141029192737.GG6582@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41817 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755465AbaJ2T1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 15:27:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When vnet_event_napi re-enables interrupts, it should
reset LDC_EVENT_DATA_READY as an optimization.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index c390a27..7ada479 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -760,6 +760,7 @@ static int vnet_poll(struct napi_struct *napi, int budget)
 
 	if (processed < budget) {
 		napi_complete(napi);
+		port->rx_event &= ~LDC_EVENT_DATA_READY;
 		vio_set_intr(vio->vdev->rx_ino, HV_INTR_ENABLED);
 	}
 	return processed;
-- 
1.8.4.2

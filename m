From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH 2/3 net-next] sunvnet: vnet_ack() should check if !start_cons
 to send a missed trigger
Date: Sat, 8 Nov 2014 20:42:10 -0500
Message-ID: <20141109014210.GD31217@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, david.stevens@oracle.com
To: davem@davemloft.net, sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23153 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbaKIBmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Nov 2014 20:42:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As per comments in vnet_start_xmit, for the edge case
when outgoing vnet_start_xmit() data and an incoming STOPPED
ACK cross each other in flight, we may need to send the missed
START trigger from maybe_tx_wakeup() after checking for a
false value of start_cons

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index deb395a..826b385 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -572,7 +572,7 @@ static int vnet_ack(struct vnet_port *port, void *msgbuf)
 	 */
 	dr->cons = next_idx(end, dr);
 	desc = vio_dring_entry(dr, dr->cons);
-	if (desc->hdr.state == VIO_DESC_READY && port->start_cons) {
+	if (desc->hdr.state == VIO_DESC_READY && !port->start_cons) {
 		/* vnet_start_xmit() just populated this dring but missed
 		 * sending the "start" LDC message to the consumer.
 		 * Send a "start" trigger on its behalf.
-- 
1.8.4.2

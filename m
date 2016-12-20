From: Suresh Reddy <suresh.reddy@broadcom.com>
Subject: [PATCH net] be2net: Increase skb headroom size to 256 bytes
Date: Tue, 20 Dec 2016 10:14:30 -0500
Message-ID: <20161220151430.11115-1-suresh.reddy@broadcom.com>
To: netdev@vger.kernel.org, kalesh-anakkur.purayil@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lpdvsmtp02.broadcom.com ([192.19.219.146]:57836 "EHLO
        relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932631AbcLTPOi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 10:14:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh A P <kalesh-anakkur.purayil@broadcom.com>

The driver currently allocates 128 bytes of skb headroom.
This was found to be insufficient with some configurations
like Geneve tunnels, which resulted in skb head reallocations.

Increase the headroom to 256 bytes to fix this.

Signed-off-by: Kalesh A P <kalesh-anakkur.purayil@broadcom.com>
Signed-off-by: Suresh Reddy <suresh.reddy@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 6cfa63a..4c30c44 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -65,7 +65,7 @@
 /* Number of bytes of an RX frame that are copied to skb->data */
 #define BE_HDR_LEN		((u16) 64)
 /* allocate extra space to allow tunneling decapsulation without head reallocation */
-#define BE_RX_SKB_ALLOC_SIZE (BE_HDR_LEN + 64)
+#define BE_RX_SKB_ALLOC_SIZE	256
 
 #define BE_MAX_JUMBO_FRAME_SIZE	9018
 #define BE_MIN_MTU		256
-- 
2.10.1

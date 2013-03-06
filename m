From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 2/2] bnx2x: use the default NAPI weight
Date: Tue, 05 Mar 2013 17:57:47 -0800
Message-ID: <1362535067.15793.146.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:45925 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767Ab3CFB5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 20:57:50 -0500
Received: by mail-oa0-f41.google.com with SMTP id i10so12104231oag.0
        for <netdev@vger.kernel.org>; Tue, 05 Mar 2013 17:57:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

BQL (Byte Queue Limits) proper operation needs TX completion
being serviced in a timely fashion.

bnx2x uses a non standard NAPI poll weight, and thats not fair to other
napi poll handlers, and even not reasonable.

Use the default value instead.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h     |    1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h |    4 ++--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index e4605a9..9577cce 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -492,7 +492,6 @@ enum bnx2x_tpa_mode_t {
 struct bnx2x_fastpath {
 	struct bnx2x		*bp; /* parent */
 
-#define BNX2X_NAPI_WEIGHT       128
 	struct napi_struct	napi;
 	union host_hc_status_block	status_blk;
 	/* chip independed shortcuts into sb structure */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index aee7671..8d158d8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -834,7 +834,7 @@ static inline void bnx2x_add_all_napi_cnic(struct bnx2x *bp)
 	/* Add NAPI objects */
 	for_each_rx_queue_cnic(bp, i)
 		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
-			       bnx2x_poll, BNX2X_NAPI_WEIGHT);
+			       bnx2x_poll, NAPI_POLL_WEIGHT);
 }
 
 static inline void bnx2x_add_all_napi(struct bnx2x *bp)
@@ -844,7 +844,7 @@ static inline void bnx2x_add_all_napi(struct bnx2x *bp)
 	/* Add NAPI objects */
 	for_each_eth_queue(bp, i)
 		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
-			       bnx2x_poll, BNX2X_NAPI_WEIGHT);
+			       bnx2x_poll, NAPI_POLL_WEIGHT);
 }
 
 static inline void bnx2x_del_all_napi_cnic(struct bnx2x *bp)

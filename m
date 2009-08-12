From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 15/36] bnx2x: Prefetch the page containing the BD
 descriptor
Date: Wed, 12 Aug 2009 21:23:20 +0300
Message-ID: <1250101400.27379.167.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Vladislav Zolotarov" <vladz@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3470 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753115AbZHLSYP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:24:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index e6fde5e..594168a 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1497,6 +1497,13 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 		bd_prod = RX_BD(bd_prod);
 		bd_cons = RX_BD(bd_cons);
 
+		/* Prefetch the page containing the BD descriptor
+		   at producer's index. It will be needed when new skb is
+		   allocated */
+		prefetch((void *)(PAGE_ALIGN((unsigned long)
+					     (&fp->rx_desc_ring[bd_prod])) -
+				  PAGE_SIZE + 1));
+
 		cqe = &fp->rx_comp_ring[comp_ring_cons];
 		cqe_fp_flags = cqe->fast_path_cqe.type_error_flags;
 
-- 
1.5.4.3





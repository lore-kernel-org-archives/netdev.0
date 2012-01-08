From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] 8139cp: fix missing napi_gro_flush.
Date: Mon, 9 Jan 2012 00:41:33 +0100
Message-ID: <20120108234133.GA2785@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Marin Glibic <zhilla2@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:35741 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754867Ab2AHXvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2012 18:51:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver uses __napi_complete and napi_gro_receive. Without it, the
driver hits the BUG_ON(n->gro_list) assertion hard in __napi_complete.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Tested-by: Marin Glibic <zhilla2@gmail.com>
---

 This is a candidate for -stable.

 drivers/net/ethernet/realtek/8139cp.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index cc6b391..abc7907 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -563,6 +563,7 @@ rx_next:
 		if (cpr16(IntrStatus) & cp_rx_intr_mask)
 			goto rx_status_loop;
 
+		napi_gro_flush(napi);
 		spin_lock_irqsave(&cp->lock, flags);
 		__napi_complete(napi);
 		cpw16_f(IntrMask, cp_intr_mask);
-- 
1.7.6.4

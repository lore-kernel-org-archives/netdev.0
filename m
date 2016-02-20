From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 1/3] bnxt_en: Poll link at the end of __bnxt_open_nic().
Date: Fri, 19 Feb 2016 19:43:19 -0500
Message-ID: <1455929001-12039-2-git-send-email-michael.chan@broadcom.com>
References: <1455929001-12039-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:20683
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1428904AbcBTAnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 19:43:24 -0500
In-Reply-To: <1455929001-12039-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>

When shutting down the NIC, we shutdown async event processing before
freeing all the rings.  If there is a link change event during reset, the
driver may miss it and the link state may be incorrect after the NIC is
re-opened.  Poll the link at the end of __bnxt_open_nic() to get the
correct link status.

Signed-off-by Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 82f4e6d..9b56058 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4662,6 +4662,7 @@ static int __bnxt_open_nic(struct bnxt *bp, bool irq_re_init, bool link_re_init)
 	/* Enable TX queues */
 	bnxt_tx_enable(bp);
 	mod_timer(&bp->timer, jiffies + bp->current_interval);
+	bnxt_update_link(bp, true);
 
 	return 0;
 
-- 
1.8.3.1

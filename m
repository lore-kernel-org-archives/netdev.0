From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCHv1] net-bnx2x: Force link UP when the interface is in LOOPBACK mode
Date: Wed, 30 Jan 2013 09:00:12 -0800
Message-ID: <1359565212-11104-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: Eilon Greenstein <eilong@broadcom.com>,
	Yaniv <yanivr@broadcom.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:40980 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753737Ab3A3RAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 12:00:16 -0500
Received: by mail-yh0-f74.google.com with SMTP id z6so170167yhz.3
        for <netdev@vger.kernel.org>; Wed, 30 Jan 2013 09:00:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the interface does not have carrier but when it's put into
loopback mode (for tests), it does not make sense to not have
the carrier. So force it!

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
v1.0 : Added check to ensure it's not forced in LOOPBACK_EXT mode.

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 859df751345e..c6da77fa9d07 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -4748,6 +4748,12 @@ void bnx2x_link_status_update(struct link_params *params,
 	vars->link_status = REG_RD(bp, params->shmem_base +
 				   offsetof(struct shmem_region,
 					    port_mb[port].link_status));
+
+	/* Force link UP in non LOOPBACK_EXT loopback mode(s) */
+	if (bp->link_params.loopback_mode != LOOPBACK_NONE &&
+	    bp->link_params.loopback_mode != LOOPBACK_EXT)
+		vars->link_status |= LINK_STATUS_LINK_UP;
+
 	if (bnx2x_eee_has_cap(params))
 		vars->eee_status = REG_RD(bp, params->shmem2_base +
 					  offsetof(struct shmem2_region,
-- 
1.8.1

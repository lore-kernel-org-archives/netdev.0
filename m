From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH] net-bnx2x: Force link UP when the interface is in LOOPBACK mode
Date: Tue, 29 Jan 2013 17:51:55 -0800
Message-ID: <1359510715-12099-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: Eilon Greenstein <eilong@broadcom.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f202.google.com ([209.85.128.202]:34639 "EHLO
	mail-ve0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560Ab3A3C6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 21:58:38 -0500
Received: by mail-ve0-f202.google.com with SMTP id m1so26108ves.3
        for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 18:58:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the interface does not have carrier but when it's put into
loopback mode (for tests), it does not make sense to not have
the carrier. So force it!

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 859df751345e..91af55586bbc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -4748,6 +4748,11 @@ void bnx2x_link_status_update(struct link_params *params,
 	vars->link_status = REG_RD(bp, params->shmem_base +
 				   offsetof(struct shmem_region,
 					    port_mb[port].link_status));
+
+	/* Force link UP in loopback mode */
+	if (bp->link_params.loopback_mode != LOOPBACK_NONE)
+		vars->link_status |= LINK_STATUS_LINK_UP;
+
 	if (bnx2x_eee_has_cap(params))
 		vars->eee_status = REG_RD(bp, params->shmem2_base +
 					  offsetof(struct shmem2_region,
-- 
1.8.1

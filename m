From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 4/4] netback: correct netbk_tx_err to handle wrap around.
Date: Wed, 6 Feb 2013 17:18:18 +0000
Message-ID: <1360171098-1240-4-git-send-email-ian.campbell@citrix.com>
References: <1360171081.32479.20.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xen-devel@lists.xen.org>, Ian Campbell <ian.campbell@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:60178 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756440Ab3BFRSV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 12:18:21 -0500
In-Reply-To: <1360171081.32479.20.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Acked-by: Jan Beulich <JBeulich@suse.com>
---
 drivers/net/xen-netback/netback.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 1a99288..28d5e06 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -880,7 +880,7 @@ static void netbk_tx_err(struct xenvif *vif,
 
 	do {
 		make_tx_response(vif, txp, XEN_NETIF_RSP_ERROR);
-		if (cons >= end)
+		if (cons == end)
 			break;
 		txp = RING_GET_REQUEST(&vif->tx, cons++);
 	} while (1);
-- 
1.7.2.5

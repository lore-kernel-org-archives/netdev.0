From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH v2 4/4] netback: correct netbk_tx_err to handle wrap around.
Date: Thu, 7 Feb 2013 09:41:38 +0000
Message-ID: <1360230098-28218-4-git-send-email-ian.campbell@citrix.com>
References: <1360230078.32479.41.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xen-devel@lists.xen.org>, Ian Campbell <ian.campbell@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:56517 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755656Ab3BGJll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 04:41:41 -0500
In-Reply-To: <1360230078.32479.41.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Acked-by: Jan Beulich <JBeulich@suse.com>
Cc: <stable@vger.kernel.org> # 3.0+
---
 drivers/net/xen-netback/netback.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index dcb2d4d..2b9520c 100644
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

From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net] xen-netback: don't move event pointer in TX credit timeout callback
Date: Thu, 15 May 2014 12:24:16 +0100
Message-ID: <1400153056-12793-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jajcus@jajcus.net>, Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Paul Durrant <paul.durrant@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:33657 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751376AbaEOLYS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 07:24:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

... otherwise the frontend will try to send TX event all the time, even
if no progress can be made. The pointer should only be advanced by the
routine that actually processes the ring.

Reported-by: Jacek Konieczny <jajcus@jajcus.net>
Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Paul Durrant <paul.durrant@citrix.com>
---
 drivers/net/xen-netback/netback.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 7666540..8e2cbeb 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -658,7 +658,7 @@ void xenvif_check_rx_xenvif(struct xenvif *vif)
 {
 	int more_to_do;
 
-	RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, more_to_do);
+	more_to_do = RING_HAS_UNCONSUMED_REQUESTS(&vif->tx);
 
 	if (more_to_do)
 		napi_schedule(&vif->napi);
-- 
1.7.10.4

From: Pantelis Koukousoulas <pktoss@gmail.com>
Subject: [PATCH] Fix asix-based cards connecting to 10/100Mbs LAN.
Date: Thu, 20 Nov 2008 11:47:43 +0200
Message-ID: <1227174463-18158-1-git-send-email-pktoss@gmail.com>
Cc: Pantelis Koukousoulas <pktoss@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:37181 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753962AbYKTJrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 04:47:43 -0500
Received: by ug-out-1314.google.com with SMTP id 39so220920ugf.37
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2008 01:47:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add AX_MEDIUM_ENCK also when speed = 10/100Mbps. This allows my belkin
 f5d5055 to work with my 100Mbps switch and with an old 10Mbps ISA card.
 Without this patch, the card is recognized and the interface is brought
 up fine, but no packets actually flow through the interface.

Signed-off-by: Pantelis Koukousoulas <pktoss@gmail.com>
Acked-by: David Hollis <dhollis@davehollis.com>
---
 drivers/net/usb/asix.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index e12cdb4..de57490 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -1102,12 +1102,14 @@ static int ax88178_link_reset(struct usbnet *dev)
 	mode = AX88178_MEDIUM_DEFAULT;
 
 	if (ecmd.speed == SPEED_1000)
-		mode |= AX_MEDIUM_GM | AX_MEDIUM_ENCK;
+		mode |= AX_MEDIUM_GM;
 	else if (ecmd.speed == SPEED_100)
 		mode |= AX_MEDIUM_PS;
 	else
 		mode &= ~(AX_MEDIUM_PS | AX_MEDIUM_GM);
 
+	mode |= AX_MEDIUM_ENCK;
+
 	if (ecmd.duplex == DUPLEX_FULL)
 		mode |= AX_MEDIUM_FD;
 	else
-- 
1.5.6.3


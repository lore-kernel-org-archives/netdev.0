From: Bjorge Dijkstra <bjd@jooz.net>
Subject: [PATCH 3/8] [PATCH] Use 1KB buffer in rndis_unbind
Date: Sat, 22 Dec 2007 22:51:29 +0100
Message-ID: <11983602953865-git-send-email-bjd@jooz.net>
References: <11983602942818-git-send-email-bjd@jooz.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
To: dbrownell@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:62450 "EHLO
	viefep11-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753515AbXLVVvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2007 16:51:36 -0500
In-Reply-To: <11983602942818-git-send-email-bjd@jooz.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

rndis_command requires the caller to pass in a buffer of at least 1KB.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Signed-off-by: Bjorge Dijkstra <bjd@jooz.net>
---
 drivers/net/usb/rndis_host.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index 96ef6a9..42b161c 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -577,7 +577,7 @@ static void rndis_unbind(struct usbnet *dev, struct usb_interface *intf)
 	struct rndis_halt	*halt;
 
 	/* try to clear any rndis state/activity (no i/o from stack!) */
-	halt = kzalloc(sizeof *halt, GFP_KERNEL);
+	halt = kzalloc(CONTROL_BUFFER_SIZE, GFP_KERNEL);
 	if (halt) {
 		halt->msg_type = RNDIS_MSG_HALT;
 		halt->msg_len = ccpu2(sizeof *halt);
-- 
1.5.2.5


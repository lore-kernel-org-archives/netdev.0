From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH 03/14] [rndis_host] Use 1KB buffer in rndis_unbind
Date: Sat, 26 Jan 2008 00:50:49 +0200
Message-ID: <20080125225049.11716.93868.stgit@fate.lan>
References: <20080125225032.11716.77713.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bjd@jooz.net, david-b@pacbell.net
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout4-sn1.fre.skanova.net ([81.228.11.168]:60270 "EHLO
	pne-smtpout4-sn1.fre.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759374AbYAYWu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 17:50:57 -0500
In-Reply-To: <20080125225032.11716.77713.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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


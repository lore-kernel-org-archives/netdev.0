From: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Subject: [PATCH 03/14] [rndis_host] Use 1KB buffer in rndis_unbind
Date: Sun, 20 Jan 2008 02:13:59 +0200
Message-ID: <20080120001359.25718.20460.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bjd-a1rhEgazXTw@public.gmane.org, dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

rndis_command requires the caller to pass in a buffer of at least 1KB.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Signed-off-by: Bjorge Dijkstra <bjd-a1rhEgazXTw@public.gmane.org>
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

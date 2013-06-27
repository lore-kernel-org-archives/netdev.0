From: David Chang <dchang@suse.com>
Subject: [PATCH 2/2 net-next] usbnet: ax88179_178a: add .reset_resume hook
Date: Thu, 27 Jun 2013 17:16:43 +0800
Message-ID: <1372324603-4556-2-git-send-email-dchang@suse.com>
References: <1372324603-4556-1-git-send-email-dchang@suse.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jlee@suse.com,
	David Chang <dchang@suse.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372324603-4556-1-git-send-email-dchang@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I tested with the AX88179 usb dongle, if without .reset_resume hook,
after S3/S4 resume you have to enable network interface or reload the
dirver module manually otherwise the network interface can not work.

Signed-off-by: David Chang <dchang@suse.com>
---
 drivers/net/usb/ax88179_178a.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index 7ce243b..1e3c302 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -1433,6 +1433,7 @@ static struct usb_driver ax88179_178a_driver = {
 	.probe =	usbnet_probe,
 	.suspend =	ax88179_suspend,
 	.resume =	ax88179_resume,
+	.reset_resume =	ax88179_resume,
 	.disconnect =	usbnet_disconnect,
 	.supports_autosuspend = 1,
 	.disable_hub_initiated_lpm = 1,
-- 
1.8.1.4

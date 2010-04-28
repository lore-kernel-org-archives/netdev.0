From: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 1/1] net/usb: initiate sync sequence in sierra_net.c driver
Date: Wed, 28 Apr 2010 16:28:24 -0700
Message-ID: <1272497304.8835.2.camel@Linuxdev4-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>, <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Subject: [PATCH 1/1] net/usb: initiate sync sequence in sierra_net.c driver
From: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>

The following patch adds the initiation of the sync sequence to
"sierra_net_bind()". If this step is omitted, the modem will never sync up
with the host and it will not be possible to establish a data connection.
This is a high priority patch.

This patch has been checked against net-2.6 tree.
Signed-off-by: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
Signed-off-by: Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
Tested-by: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
---
 drivers/net/usb/sierra_net.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.c
index a44f9e0..f1942d6 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -789,6 +789,9 @@ static int sierra_net_bind(struct usbnet *dev, struct usb_interface *intf)
 	/* prepare sync message from template */
 	memcpy(priv->sync_msg, sync_tmplate, sizeof(priv->sync_msg));
 
+	/* initiate the sync sequence */
+	sierra_net_dosync(dev);
+
 	return 0;
 }
 
-- 
1.5.4.3



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

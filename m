From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: [PATCH 3/3] rtl8152: correct speed testing
Date: Mon,  2 May 2016 13:06:14 +0200
Message-ID: <1462187174-17180-3-git-send-email-oneukum@suse.com>
References: <1462187174-17180-1-git-send-email-oneukum@suse.com>
Cc: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>, Oliver Neukum <ONeukum-IBi9RG/b67k@public.gmane.org>
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1462187174-17180-1-git-send-email-oneukum-IBi9RG/b67k@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Allow for SS+ USB

Signed-off-by: Oliver Neukum <ONeukum-IBi9RG/b67k@public.gmane.org>
---
 drivers/net/usb/r8152.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index d1f78c2..3f9f6ed 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3366,7 +3366,7 @@ static void r8153_init(struct r8152 *tp)
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_LED_FEATURE, ocp_data);
 
 	ocp_data = FIFO_EMPTY_1FB | ROK_EXIT_LPM;
-	if (tp->version == RTL_VER_04 && tp->udev->speed != USB_SPEED_SUPER)
+	if (tp->version == RTL_VER_04 && tp->udev->speed < USB_SPEED_SUPER)
 		ocp_data |= LPM_TIMER_500MS;
 	else
 		ocp_data |= LPM_TIMER_500US;
@@ -4211,6 +4211,7 @@ static int rtl8152_probe(struct usb_interface *intf,
 
 	switch (udev->speed) {
 	case USB_SPEED_SUPER:
+	case USB_SPEED_SUPER_PLUS:
 		tp->coalesce = COALESCE_SUPER;
 		break;
 	case USB_SPEED_HIGH:
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: [PATCHv2] hso: fix disable_net
Date: Thu, 25 Nov 2010 14:40:50 +0100
Message-ID: <1290692450.2112.21.camel@filip-linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jhovold-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, pki-/L4m51SJ8HhmR6Xm/wNWPw@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The HSO driver incorrectly creates a serial device instead of a net
device when disable_net is set. It shouldn't create anything for the
network interface.

Signed-off-by: Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
---
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index b154a94..1b755ae 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2994,12 +2994,14 @@ static int hso_probe(struct usb_interface *interface,
 
 	case HSO_INTF_BULK:
 		/* It's a regular bulk interface */
-		if (((port_spec & HSO_PORT_MASK) == HSO_PORT_NETWORK) &&
-		    !disable_net)
-			hso_dev = hso_create_net_device(interface, port_spec);
-		else
+		if ((port_spec & HSO_PORT_MASK) == HSO_PORT_NETWORK) { 
+			if(!disable_net)
+				hso_dev =
+				    hso_create_net_device(interface, port_spec);
+		} else {
 			hso_dev =
 			    hso_create_bulk_serial_device(interface, port_spec);
+		}
 		if (!hso_dev)
 			goto exit;
 		break;

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

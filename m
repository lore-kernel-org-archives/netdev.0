From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: strange code in cdc-ncm
Date: Sat, 14 May 2011 22:58:08 +0200
Message-ID: <201105142258.08830.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I was looking at this code:

static void cdc_ncm_unbind(struct usbnet *dev, struct usb_interface *intf)
{
	struct cdc_ncm_ctx *ctx = (struct cdc_ncm_ctx *)dev->data[0];
	struct usb_driver *driver;

	if (ctx == NULL)
		return;		/* no setup */

	driver = driver_of(intf);

	usb_set_intfdata(ctx->data, NULL);
	usb_set_intfdata(ctx->control, NULL);
	usb_set_intfdata(ctx->intf, NULL);

	/* release interfaces, if any */
	if (ctx->data_claimed) {
		usb_driver_release_interface(driver, ctx->data);
		ctx->data_claimed = 0;
	}

	if (ctx->control_claimed) {
		usb_driver_release_interface(driver, ctx->control);
		ctx->control_claimed = 0;
	}

It seems a bit strange to me. If you may or may not have claimed an interface,
how can you unconditionally zero out intfdata?

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

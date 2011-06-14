From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH] net/usb: Add Samsung Kalmia driver for Samsung GT-B3730
Date: Tue, 14 Jun 2011 11:46:19 +0200
Message-ID: <201106141146.19097.oneukum@suse.de>
References: <20110611200625.GB14582@kroah.com> <201106141049.39150.oneukum@suse.de> <4DF72A90.1070702@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Marius B. Kotsbak" <marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org>
To: Marius Kotsbak <marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4DF72A90.1070702-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 14. Juni 2011, 11:32:00 schrieb Marius Kotsbak:
> Den 14. juni 2011 10:49, skrev Oliver Neukum:
> > Am Samstag, 11. Juni 2011, 23:55:18 schrieb Marius B. Kotsbak:
> >
> >> +static int
> >> +kalmia_init_and_get_ethernet_addr(struct usbnet *dev, u8 *ethernet_addr)
> >> +{
> >> +	char init_msg_1[] =
> >> +		{ 0x57, 0x50, 0x04, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00,
> >> +		0x00, 0x00 };
> >> +	char init_msg_2[] =
> >> +		{ 0x57, 0x50, 0x04, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0xf4,
> >> +		0x00, 0x00 };
> >> +	char receive_buf[28];
> > You are doing DMA on the stack. This will fail on some architectures.
> >
> 
> Okay, a bit strange that this API is available then. Which API functions 
> should be used in this case?

The API is correct. You just need to copy the init strings into buffers
allocated with kmalloc.

> >> +	if (status<  0) {
> >> +		usb_set_intfdata(intf, NULL);
> >> +		usb_driver_release_interface(driver_of(intf), intf);
> >> +		return status;
> > Why are you doing this? What is to be undone?
> 
> You mean the 3 last lines? I just did the same as done in another 
> similar usbnet based driver. Is it incorrect if the init fails?

Yes, the last three lines. If all drivers do that this is an opportunity to
share common code in usbnet. I'll look at it. 

> >> +static int
> >> +kalmia_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
> >> +{
> >> +	/*
> >> +	 * Our task here is to strip off framing, leaving skb with one
> >> +	 * data frame for the usbnet framework code to process.
> >> +	 */
> >> +	const u8 HEADER_END_OF_USB_PACKET[] =
> >> +		{ 0x57, 0x5a, 0x00, 0x00, 0x08, 0x00 };
> >> +	const u8 EXPECTED_UNKNOWN_HEADER_1[] =
> >> +		{ 0x57, 0x43, 0x1e, 0x00, 0x15, 0x02 };
> >> +	const u8 EXPECTED_UNKNOWN_HEADER_2[] =
> >> +		{ 0x57, 0x50, 0x0e, 0x00, 0x00, 0x00 };
> > What does the compiler do to this declaration?
> 
> Not sure I understand what you mean here.

Will the compiler put those strings into the image or build them on
the stack each time the function is called? Shouldn't they be static?

> >> +	u8 i = 0;
> > Why not int?
> 
> I can change that. Thought int was not to be used because it is of 
> unknown size.

Well, then are you sure i will never be larger than 255?

> Anyway it should not do any damage for anyone (I think even the driver 
> disk is available with this included). The module could in fact also do 
> the switch into modem mode to avoid the dependency on usb_modeswitch.

Please don't do that. It has been decided to put such things into usb_modeswitch
for now.

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

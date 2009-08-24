From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 1/1] iwmc3200: add more SDIO device ids
Date: Mon, 24 Aug 2009 16:21:58 -0700
Message-ID: <1251156118.2950.82.camel@localhost.localdomain>
References: <1251149659-32212-1-git-send-email-tomas.winkler@intel.com>
	 <43e72e890908241436o5f30cfe6xa7bdda8b25ac082@mail.gmail.com>
	 <1ba2fa240908241520q5be2060co145ec0745954dcf0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
To: Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1ba2fa240908241520q5be2060co145ec0745954dcf0-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Tomas,

> >> add WiFi BGN SKU and WiMAX 2.4GHz SKU device ids
> >>
> >> Cc:inaky.perez-gonzalez-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
> >> Cc:cindy.h.kao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
> >> Cc:yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
> >> Signed-off-by: Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> >
> > Since it seems we are preferring to not do this for PCI for cases
> > where the ID will only be used for 1 device perhaps its best to remove
> > all those ids and stuff them directly into the intel driver itself
> > that will use it.
> >
> I don't have strong opinion about it but this is the current habit
> IIRC there was a mail thread that explicitly asked to move SDIO IDs
> there,  of course I cannot locate it right now :(

first thing is that IDs should only be added if there are users for it.
I am missing the patches that are actually using them. Send them all
together.

Second, we have to establish what is the preferred method of IDs for the
SDIO subsystem. In general I would prefer we have a global policy for
this, but in reality it is up to the subsystem maintainers.

My personal vote is for keeping all IDs inside the drivers. And I also
prefer to keep the plain hex values and just put a comment above them
which device this is. Something like this:

static struct usb_device_id btusb_table[] = {
	/* Generic Bluetooth USB device */
	{ USB_DEVICE_INFO(0xe0, 0x01, 0x01) },

	/* AVM BlueFRITZ! USB v2.0 */
	{ USB_DEVICE(0x057c, 0x3800) },

	{ }	/* Terminating entry */
};

Regards

Marcel


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Emil Goode <emilgoode-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2 v2] usbnet: fix bad header length bug
Date: Mon, 10 Feb 2014 13:00:48 +0100
Message-ID: <20140210115812.GA4278@lianli>
References: <1391987174-21828-1-git-send-email-emilgoode@gmail.com>
 <1392014458.21271.6.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Mark Brown <broonie-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Glen Turner <gdt-pRLresKaOUyHXe+LvDLADg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1392014458.21271.6.camel-B2T3B9s34ElbnMAlSieJcQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 10, 2014 at 07:40:58AM +0100, Oliver Neukum wrote:
> On Mon, 2014-02-10 at 00:06 +0100, Emil Goode wrote:
> > The AX88772B occasionally send rx packets that cross urb boundaries
> > and the remaining partial packet is sent with no hardware header.
> > When the buffer with a partial packet is of less number of octets
> > than the value of hard_header_len the buffer is discarded by the
> > usbnet module. This is causing dropped packages and error messages
> > in dmesg.
> > 
> > This can be reproduced by using ping with a packet size
> > between 1965-1976.
> 
> Well, then how about simply removing the check?
> It seems to have outlived its usefulness.
> 
> 	Regards
> 		Oliver
> 
>

I did consider that and I think it is probably the best thing to do.
However, I think the removal of the check could have negative effects
on the other minidrivers, at least the qmi_wwan minidriver explicitly
states that it is depending on this check to be made in rx_complete().

For safety the check could be added at the top of the rx_fixup callback
of the affected minidrivers.

There are devices that depend on the usbnet module that do not have
a rx_fixup callback assigned to it's driver_info struct, the check
could be added for these in the rx_process function.

This led me to think it would be a lot of noise about a small check :)

My conclusion is that 12 rx_fixup callbacks might need the check
to be added. There are 18 driver_info structs with no rx_fixup
callback assigned, these devices might need the check to be added
to the rx_process function.

Patches could be sent out to notify the affected minidrivers of the
change and hopefully someone has the hardware to test if it's 
necessary to add the check to the minidriver?

I'm happy to do this if it seem like a good idea.

Best regards,

Emil Goode
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH] net: qmi_wwan: Add USB IDs for MDM6600 modem on Motorola
 Droid 4
Date: Sun, 19 Mar 2017 10:35:26 -0700
Message-ID: <20170319173526.GD20572@atomide.com>
References: <20170319161957.6625-1-tony@atomide.com>
 <87lgs15iun.fsf@miraculix.mork.no>
 <20170319170254.GB20572@atomide.com>
 <87fui95gjo.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-omap@vger.kernel.org, Marcel Partap <mpartap@gmx.net>,
        Michael Scott <michael.scott@linaro.org>
To: =?utf-8?B?QmrDuHJu?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from muru.com ([72.249.23.125]:40550 "EHLO muru.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751943AbdCSRfb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 19 Mar 2017 13:35:31 -0400
Content-Disposition: inline
In-Reply-To: <87fui95gjo.fsf@miraculix.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Bjørn Mork <bjorn@mork.no> [170319 10:23]:
> Tony Lindgren <tony@atomide.com> writes:
> > And the v3.8 kernel also has drivers/usb/serial/mdm6600.c:
> >
> > +static const struct usb_device_id mdm6600_id_table[] = {
> > +       { USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x2a70, 0xff, 0xff, 0xff) },
> > +        /* MDM9600 */
> > +       { USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x2e0a, 0xff, 0xff, 0xff) },
> > +       { USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x900e, 0xff, 0xff, 0xff) },
> > +       { },
> > +};
> 
> 
> Yes, looks like they consitently use ff/ff/ff for serial functions and
> ff/fb/ff for QMI functions.  So adding a vendor rule seems appropriate.

OK

> > And then in drivers/usb/serial/moto_flashqsc.c:
> >
> > +static struct usb_device_id id_table[] = {
> > +       {USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x2a63, 0x0a, 0, 0)},
> > +       {USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x4281, 0x0a, 0, 0xfc)},
> > +       {USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x2db4, 0x0a, 0, 0xfc)},
> > +       {USB_DEVICE(0x22b8, 0x4260)},
> > +       {USB_DEVICE(0x22b8, 0x426D)},
> > +       {},
> > +};
> 
> This on the other hand, is something I hope I don't have to review :)
> The 0x0a class (CDC Data) is always part of a multi-interface function,
> and you would normally match on the control interface.

No idea about that one.. Presumably we can ignore it for now :)

> > Where the 0x4260 and 0x426d seem to be for the flash mode of the
> > Wrigley3GLTE modem.
> >
> > See also lsusb -v output below. No idea if there's a Windows driver
> > .inf file for this. Most likely whatever Windows driver is just using the
> > generic Android USB driver(s). I know the USB on droid 4 can be multiplexed
> > to have MDM6600 directly accessed, but I think that's only used for
> > debugging the modem as that mode needs to be selected in the bootloader
> > temporarily using volume keys.
> >
> > With the configuration in my patch, modprobe of qmi_wwan produces four
> > wwan interfaces if that matters.
> 
> And I assume they all work?

Yeah the network scan shows networks on all four interfaces.

> >> The reason I ask is that I'd hate to have reports of other Motorola
> >> devices where ff/fb/ff was used for some other USB function.  Yes, that
> >> would be stupid.  But still... Experience shows that we cannot rule out
> >> stupid when we consider USB descriptors.
> >
> > Yes thanks for checking. If you prefer to set it up in some other
> > way, or need more info, please let me know.
> 
> No, it all looks very sane to me, given your explanation. Just wanted to
> be absolutely sure. Thanks a lot.
> 
> 
> Acked-by: Bjørn Mork <bjorn@mork.no>

OK thanks,

Tony

From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: [Fwd: Re: Fwd: [PATCH] Cleanup hso rfkill error handling [was: 2.6.28-rc2
 / hso driver oops]]
Date: Thu, 06 Nov 2008 13:07:33 +0100
Message-ID: <4912DE05.1050208@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
To: Cedric Vivier <cedricv-ezYTijPLdFXQT0dZR+AlfA@public.gmane.org>,
	Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

See if this patch fixes things up, I think it might,, I hope it applies cleanly
& let the mailing lists know if the patch works

If you don't like fixing this patch up try getting it off the mailing lists.

-------- Original Message --------
Subject: Re: Fwd: [PATCH] Cleanup hso rfkill error handling [was: 2.6.28-rc2 / hso driver oops]
Date: Thu, 30 Oct 2008 11:14:16 +0000
From: Andrew Bird (Sphere Systems) <ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org>
Organization: Sphere Systems Ltd
To: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
References: <200810301034.13105.ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org> <4909934B.90709-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>

Hi Denis,
	Well I think you need to submit a patch to the /MAINTAINERS file adding a 
subsection for HSO with person name & email address. It probably should be 
sent via Greg Kroah-Hatman. At the very least get an author/copyright 
notice/date added to the top of hso.c too. Getting added as a maintainer 
should help your patch inclusion efforts too.


Best regards,


Andrew


On Thursday 30 October 2008, Denis Joseph Barrow wrote:
> Hi Andrew,
> I consider myself as a maintainer of the hso driver, not the only one
> though. How do I officially become a maintainer?
> I'm concentrating on developing a new troublesome modem driver at the
> moment & won't get a chance to active again on hso driver for at a month or
> two. I'm a bad juggler so it would be good if someone else concentrated on
> fixes to hso other than me for the moment.
> I have posted at least 4 patches to the linux usb & linux netdev
> mailing list & they weren't accepted yet & I need to
> respin them for the latest kernels.
>
> Andrew Bird (Sphere Systems) wrote:
> > Hi Denis,
> > 	I don't know whether you are still working on the hso driver, but if so
> > this may interest you. You might also want to add yourself as maintainer
> > for the driver, quite a few of these things get cc'd to me in the absence
> > of a formal maintainer, but I'm no longer working on the project.
> >
> >
> > Best regards,
> >
> >
> > Andrew
> >
> >
> > ------------------------------------------------------------------------
> >
> > Subject:
> > [PATCH] Cleanup hso rfkill error handling [was: 2.6.28-rc2 / hso driver
> > oops]
> > From:
> > Jonathan McDowell <noodles-4QvXXjU8Dv4@public.gmane.org>
> > Date:
> > Thu, 30 Oct 2008 10:27:46 +0000
> > To:
> > linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> >
> > To:
> > linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > CC:
> > Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, Andrew Bird
> > <ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org>
> >
> > On Wed, Oct 29, 2008 at 07:40:11PM +0000, Ben Hutchings wrote:
> >> On Wed, 2008-10-29 at 16:40 +0000, Jonathan McDowell wrote:
> >>> Hi.
> >>>
> >>> Tried out 2.6.28-rc2 today on my EEE 901 and my Option Icon 225 and got
> >>> the following oops:
> >>>
> >>> hso: drivers/net/usb/hso.c: 1.2 Option Wireless
> >>> usbcore: registered new interface driver hso
> >>> usb 2-2: new full speed USB device using uhci_hcd and address 3
> >>> usb 2-2: configuration #1 chosen from 1 choice
> >>> hso0: Disabled Privacy Extensions
> >>> BUG: unable to handle kernel NULL pointer dereference at 000000d0
> >>> IP: [<c03589b9>] dev_driver_string+0x1/0x2a
> >>
> >> Something passed a null device pointer to dev_printk().
> >>
> >> [...]
> >>
> >>> [<f81b8265>] ? hso_create_net_device+0x305/0x32d [hso]
> >>
> >> [...]
> >>
> >> I think that hso_create_rfkill() is the culprit here (and has been
> >> inlined into hso_create_net_device()).  It's using hso_dev->dev as the
> >> first argument to dev_err() and it doesn't look like that field is
> >> initialised except by kzalloc.  At a guess, it should be using
> >> &hso_dev->usb->dev.
> >
> > Yup, this appears to be the problem, thanks. I think &hso_net->net->dev
> > is more intuitive for the error message, so I've used that. I've also
> > added missing line endings on the error messages and set our local
> > rfkill structure element to NULL on failure so we don't try to call
> > rfkill_unregister on driver removal if we failed to register at all.
> >
> > The patch below Works For Me (TM); the device is detected fine, can be
> > removed without problems and connects ok. I'll have a prod at why the
> > rfkill stuff isn't working next, but I believe this cleanup of the error
> > handling is appropriate no matter what the issue with registration is.
> >
> > Signed-Off-By: Jonathan McDowell <noodles-4QvXXjU8Dv4@public.gmane.org>
> >
> > -----
> > diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> > index 1164c52..9d9622b 100644
> > --- a/drivers/net/usb/hso.c
> > +++ b/drivers/net/usb/hso.c
> > @@ -2184,19 +2184,20 @@ static void hso_create_rfkill(struct hso_device
> > *hso_dev, struct usb_interface *interface)
> >  {
> >  	struct hso_net *hso_net = dev2net(hso_dev);
> > -	struct device *dev = hso_dev->dev;
> > +	struct device *dev = &hso_net->net->dev;
> >  	char *rfkn;
> >
> >  	hso_net->rfkill = rfkill_allocate(&interface_to_usbdev(interface)->dev,
> >  				 RFKILL_TYPE_WLAN);
> >  	if (!hso_net->rfkill) {
> > -		dev_err(dev, "%s - Out of memory", __func__);
> > +		dev_err(dev, "%s - Out of memory\n", __func__);
> >  		return;
> >  	}
> >  	rfkn = kzalloc(20, GFP_KERNEL);
> >  	if (!rfkn) {
> >  		rfkill_free(hso_net->rfkill);
> > -		dev_err(dev, "%s - Out of memory", __func__);
> > +		hso_net->rfkill = NULL;
> > +		dev_err(dev, "%s - Out of memory\n", __func__);
> >  		return;
> >  	}
> >  	snprintf(rfkn, 20, "hso-%d",
> > @@ -2209,7 +2210,8 @@ static void hso_create_rfkill(struct hso_device
> > *hso_dev, kfree(rfkn);
> >  		hso_net->rfkill->name = NULL;
> >  		rfkill_free(hso_net->rfkill);
> > -		dev_err(dev, "%s - Failed to register rfkill", __func__);
> > +		hso_net->rfkill = NULL;
> > +		dev_err(dev, "%s - Failed to register rfkill\n", __func__);
> >  		return;
> >  	}
> >  }
> > -----
> >
> > J.


-- 
best regards,
D.J. Barrow
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

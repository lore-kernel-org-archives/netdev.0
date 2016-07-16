From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH] dt: bindings: Add a generic ethernet device binding
Date: Sat, 16 Jul 2016 21:19:25 +0200
Message-ID: <1829519.03iRef1QQj@wuerfel>
References: <1468405204-5845-1-git-send-email-hdegoede@redhat.com> <1788846.r3134d1VMR@wuerfel> <289d5b2e-6232-2c91-f11d-774265e05125@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <289d5b2e-6232-2c91-f11d-774265e05125-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday, July 16, 2016 12:18:40 PM CEST Hans de Goede wrote:
> Hi,
> 
> On 15-07-16 22:42, Arnd Bergmann wrote:
> > On Wednesday, July 13, 2016 12:20:04 PM CEST Hans de Goede wrote:
> >> +&mmc1 {
> >> +       non-removable;
> >> +       status = "okay";
> >> +
> >> +       sdio_wifi: sdio_wifi@1 {
> >> +               compatible = "generic,ethernet"
> >> +               reg = <1>;
> >> +       };
> >> +};
> >
> > For discoverable buses, we normally use a compatible property that
> > reflects the device ID on that bus, e.g. on PCI we have "pci1A2B:3C4D"
> > and I think that makes more sense than having to come up with strings
> > for sdio devices.
> 
> 2 things:
> 
> 1) The problem here is that different batches of the same board
> (cheap chinese tablet) have different sdio wifi modules, so we
> actually cannot specify a vendor / product id as in your example.

Right, this is where we have a mismatch between original OF
that did all the device probing and provided the compatible
strings for the OS to use, and the FDT method where the bootloader
does no probing at all but relies on a complete hardware
description to be there already. I have no good solution
for that.

> 2) In some cases we do want an actual compatible because some devices
> have some oob (out-of-band) going with e.g. gpio-s which cannot be
> handled by mmc-pwrseq.

But those are the cases in which we do know the compatible
string (whether we use one from custom binding or from the
generic ID method doesnt' matter).

> > In fact, Linux completely ignores the compatible strings on those
> > buses (pci, usb, sdio, ...),
> 
> You're mostly right, but at least the brcmfmac driver looks for a
> compatible in the mmc-host child node describing its sdio function
> to see if it should check for oob irq information there.

I'm aware of that one, and not really happy with the way it turned
out, because the compatible string in that case identifies the
oldest supported chip for that driver. We normally do that when
the devices are 100% compatible, but that is not the case here
at all, so that binding violates both the conventions for
discoverable buses and those that we use for non-discoverable
buses.

> > so I think we can just do the same thing
> > using no compatible string at all.
> 
> I'm all for not using any compatible string at all, actually I submitted
> a patch for a sunxi dt file which did that and Maxime pointed out that
> the compatible is listed as Required in:
> Documentation/devicetree/bindings/mmc/mmc-card.txt
> 
> If we can agree to make it optional, then I'll happily submit a patch
> with that change and Maxime can take my sunxi dts patch as is :)

Right, I think that would be best, we should at least come up with a
general policy for that case.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

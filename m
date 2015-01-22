From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH] ethernet: atheros: Add nss-gmac driver
Date: Thu, 22 Jan 2015 11:18:50 +0100
Message-ID: <1753817.oBE21Kj2o0@wuerfel>
References: <1420754626-30121-1-git-send-email-wstephen@codeaurora.org> <1702448.pOVnDx4KzI@wuerfel> <f9cbb34c9228b2af7ed6c1c96a6aa61c.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: jcliburn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: wstephen-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <f9cbb34c9228b2af7ed6c1c96a6aa61c.squirrel-mMfbam+mt9083fI46fginR2eb7JE58TQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 22 January 2015 00:20:59 wstephen-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org wrote:
> > Right. For review purposes, I think it would be helpful to split this
> > huge patch into several steps then:
> >
> > - add a base driver
> > - add the overlay interface
> > - add the nss driver
> >
> > Ideally more of them.
> 
> The nss-drv driver is open sourced but we are currently not planning to
> upstream to linux kernel yet because we are still actively adding new
> features
> https://www.codeaurora.org/cgit/quic/qsdk/oss/lklm/nss-drv
> 
> > Thanks for the description, this sounds very interesting indeed. I do
> > have more questions though: how do you get the rules into the NSS driver?
> > Does this get handled transparently by the openvswitch driver or
> > did you have to add new user interfaces for it?
> >
> 
> No, we are not using openvswitch. We have a connection manager monitoring
> conntrack events and creates rules then send it through the interface
> built in nss-drv.
> 

I see. In this case, I think merging your new driver is not a good idea:

- We already have a driver (dwmac1000) for the ethernet hardware,
  which is known to work on a lot of hardware and has an established
  binding.

- The main difference in your new driver is the plug-in interface,
  but that has no upstream users

- The nss driver is not getting submitted, and has little chance of
  getting merged if you do, because it introduces a driver-specific
  API for something that should be hardware independent.

You can simplify your private nss code a lot if you remove the
abstraction layer and only implement ethernet features you need
in the same module, and then load either the upstream driver or
your nss driver. Make sure they use a compatible binding so the
device gets attached to just one of the two drivers. For the
built-in case, you can use the 'unbind' interface from user space
to remove the device from the dwmac1000 driver.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

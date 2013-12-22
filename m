From: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH 2/4] misc: xgene: Add base driver for APM X-Gene SoC
 Queue Manager/Traffic Manager
Date: Sat, 21 Dec 2013 16:40:23 -0800
Message-ID: <20131222004023.GA15645@kroah.com>
References: <1387507503-7565-1-git-send-email-rapatel@apm.com>
 <1387507503-7565-3-git-send-email-rapatel@apm.com>
 <20131220032002.GA32310@kroah.com>
 <CAN1v_PtWrRQ6i0HAOACGP4ahgMB1393GnZS-OG6LTyPcsnpvhg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "patches-qTEPVZfXA3Y@public.gmane.org" <patches-qTEPVZfXA3Y@public.gmane.org>,
	Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
To: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAN1v_PtWrRQ6i0HAOACGP4ahgMB1393GnZS-OG6LTyPcsnpvhg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 21, 2013 at 04:20:04PM -0800, Ravi Patel wrote:
> On Thu, Dec 19, 2013 at 7:20 PM, Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org> wrote:
> > On Thu, Dec 19, 2013 at 06:45:01PM -0800, Ravi Patel wrote:
> >> --- /dev/null
> >> +++ b/drivers/misc/xgene/qmtm/Kconfig
> >> @@ -0,0 +1,8 @@
> >> +config XGENE_QMTM
> >> +     tristate "APM X-Gene QMTM driver"
> >> +     depends on ARCH_XGENE
> >
> > What does it need from this arch in order to build?  What would be
> > needed to get it to build on other arches so that it gets some actualy
> > build testing?
> 
> In patch v2 added, depends on ARM64 || COMPILE_TEST in order to
> support build testing for other arches.
> If you think we should have no dependency at all, let us know.

That's fine, but it's pretty obvious you didn't check this as your v2
version can't build on non XGENE systems :(

> > u64 for a bitfield?  Is that even valid C?  This is pretty scary from a
> > bitfield perspective, what about different endian and addressing modes?
> 
> Currently the patch is supporting only ARM64 LE mode.
> We will fix u64 bit-field with multiple u32 bit-fields for supporting
> ARM32 LE Mode.

Don't use bitfields, use bit shifts, that way it doesn't matter what
endian the system is that it is running on at all.

> > Any chance to just use shifts to access the fields properly, like most
> > drivers do, in a endian-neutral way to get the data out and into the
> > structures?
> >
> > Same goes for the other structures in this file.
> 
> I agree with you that code with bit-mask and bit-shift takes care for
> endian-neutral mode.
> But QMTM in BE Mode, behaves differently by expecting message format
> in memory as follow:
> Swapping at 128 bits level.
> a. For each 16 bytes, group of 4 bytes needs be swapped Higher to
> lower <-> lower to higher,
> b. As well as each bytes/bit fields in the group of 4 bytes also needs
> to be swapped.
> So because of 128 bit level swap, there will be complete different
> code for bit-mask, bit-shift for BE and LE
> So to support ARM64 BE and ARM32 BE, we are planning to just
> re-arrange bit-fields reversely in the structures for BE and LE.

I'll hold off and wait to see what you create, but I think it will be
more complex than just using a bit shift...

good luck,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

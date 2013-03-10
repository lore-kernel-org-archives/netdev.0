From: Loic Domaigne <loic.domaigne-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: RFC: [PATCH 1/3] usb: cdc_ncm: patch for VMware
Date: Sun, 10 Mar 2013 22:12:27 +0100
Message-ID: <20130310211227.GA2169@feynman.loic.net>
References: <20130308210319.GA4794@feynman.loic.net>
 <1362781739.8581.5.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1362781739.8581.5.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 08, 2013 at 04:28:59PM -0600, Dan Williams wrote:
> On Fri, 2013-03-08 at 22:03 +0100, Loic Domaigne wrote:
> >  
> > +/* maximum Rx URB size */
> > +/*
> > + * in the original Linux driver, the rx urb size can be up to
> > + * CDC_NCM_NTB_MAX_SIZE_RX.
> > + *
> > + * Under VMware (as of wks9), URB size greater than 16kB is a problem,
> > + * so simply adjust this define when the driver is compiled for a VMware
> > + * environment.
> > + *
> > + */
> > +#ifdef VMWARE_BUG
> > +#warning "Compiling for VMware"
> > +#define CDC_NCM_MAX_RX_URB_SIZE     16384
> > +#else
> > +#define CDC_NCM_MAX_RX_URB_SIZE     CDC_NCM_NTB_MAX_SIZE_RX
> > +#endif
> 
> I can't see how that is going to get past any sort of review.  Either
> there's some other way of detecting that the CPU is the VMWare emulated
> one or you're stuck with the bug until VMWare fixes it.

Yeah, I know.

The kludge consists to (re)compile the kernel module on the VMWare guest with
the VMWARE_BUG compiler flag set. 

We have a helper script for that task, but it's distros specific. We can 
detect automatically a VMWare emulated CPU in some cases, but not always.
As a result, we end up sometimes asking the user.

I am aware that it's not suitable as a generic solution. But waiting a fix
from VMWare might not be practical for you either.

Any better ideas?

Loic.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

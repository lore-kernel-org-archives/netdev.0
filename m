From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: RFC: [PATCH 1/3] usb: cdc_ncm: patch for VMware
Date: Mon, 11 Mar 2013 20:32:18 +0000
Message-ID: <1363033938.2608.76.camel@bwh-desktop.uk.solarflarecom.com>
References: <20130308210319.GA4794@feynman.loic.net>
	 <1362781739.8581.5.camel@dcbw.foobar.com>
	 <20130310211227.GA2169@feynman.loic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: Loic Domaigne <loic.domaigne@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6900 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752462Ab3CKUcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 16:32:21 -0400
In-Reply-To: <20130310211227.GA2169@feynman.loic.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-03-10 at 22:12 +0100, Loic Domaigne wrote:
> On Fri, Mar 08, 2013 at 04:28:59PM -0600, Dan Williams wrote:
> > On Fri, 2013-03-08 at 22:03 +0100, Loic Domaigne wrote:
> > >  
> > > +/* maximum Rx URB size */
> > > +/*
> > > + * in the original Linux driver, the rx urb size can be up to
> > > + * CDC_NCM_NTB_MAX_SIZE_RX.
> > > + *
> > > + * Under VMware (as of wks9), URB size greater than 16kB is a problem,
> > > + * so simply adjust this define when the driver is compiled for a VMware
> > > + * environment.
> > > + *
> > > + */
> > > +#ifdef VMWARE_BUG
> > > +#warning "Compiling for VMware"
> > > +#define CDC_NCM_MAX_RX_URB_SIZE     16384
> > > +#else
> > > +#define CDC_NCM_MAX_RX_URB_SIZE     CDC_NCM_NTB_MAX_SIZE_RX
> > > +#endif
> > 
> > I can't see how that is going to get past any sort of review.  Either
> > there's some other way of detecting that the CPU is the VMWare emulated
> > one or you're stuck with the bug until VMWare fixes it.
> 
> Yeah, I know.
> 
> The kludge consists to (re)compile the kernel module on the VMWare guest with
> the VMWARE_BUG compiler flag set. 
> 
> We have a helper script for that task, but it's distros specific. We can 
> detect automatically a VMWare emulated CPU in some cases, but not always.
> As a result, we end up sometimes asking the user.
> 
> I am aware that it's not suitable as a generic solution. But waiting a fix
> from VMWare might not be practical for you either.
> 
> Any better ideas?

Example from drivers/misc/vmw_balloon.c:

#include <asm/hypervisor.h>
...
	/*
	 * Check if we are running on VMware's hypervisor and bail out
	 * if we are not.
	 */
	if (x86_hyper != &x86_hyper_vmware)
		return -ENODEV;

Obviously for a non-x86-specific driver this needs to be conditional on
#ifdef CONFIG_X86.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

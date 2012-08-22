From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 15:58:57 +0100
Message-ID: <1345647537.2709.0.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>
	 <503437D4.8090706@zytor.com>
	 <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120821.193446.1534561579811962053.davem@davemloft.net>
	 <503450E2.2040504@zytor.com>
	 <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
	 <1345642009.15245.0.camel@deadeye.wl.decadent.org.uk>
	 <CA+55aFzxhxjOeFSUUJ6XQGUmnaZf7QPSz611zmj2VziEDUB_sA@mail.gmail.com>
	 <1345645499.15245.8.camel@deadeye.wl.decadent.org.uk>
	 <20120822143054.GD9803@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	David Miller <davem@davemloft.net>, <tglx@linutronix.de>,
	<mingo@redhat.com>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>, <x86@kernel.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29734 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753221Ab2HVO7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 10:59:05 -0400
In-Reply-To: <20120822143054.GD9803@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-22 at 10:30 -0400, Benjamin LaHaise wrote:
> On Wed, Aug 22, 2012 at 03:24:59PM +0100, Ben Hutchings wrote:
> > -#ifdef EFX_USE_QWORD_IO
> > +#if defined(EFX_USE_OWORD_IO)
> > +       _efx_writeo(efx, value->u128, reg);
> > +#elif defined(EFX_USE_QWORD_IO)
> >         _efx_writeq(efx, value->u64[0], reg + 0);
> >         _efx_writeq(efx, value->u64[1], reg + 8);
> >  #else
> 
> This looks like a perfect fit for write combining.  I have traces showing 
> that enabling write combining on MMIO does indeed generate a single PCIe 
> transaction on at least a couple of different current systems.  Why is 
> that not an option?

Because reordering, and see the comment at the top of this file.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

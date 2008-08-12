From: Suresh Siddha <suresh.b.siddha@intel.com>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Tue, 12 Aug 2008 11:28:11 -0700
Message-ID: <20080812182811.GA646@linux-os.sc.intel.com>
References: <200807171653.59177.wolfgang.walter@stwm.de> <20080810030521.GA2332@gondor.apana.org.au> <20080811190131.GL13158@linux-os.sc.intel.com> <200808121343.22892.wolfgang.walter@stwm.de> <20080812120213.GA22992@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wolfgang Walter <wolfgang.walter@stwm.de>,
	"Siddha, Suresh B" <suresh.b.siddha@intel.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	"viro@ZenIV.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56974 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751368AbYHLS2N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2008 14:28:13 -0400
Content-Disposition: inline
In-Reply-To: <20080812120213.GA22992@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 12, 2008 at 05:02:13AM -0700, Herbert Xu wrote:
> On Tue, Aug 12, 2008 at 01:43:22PM +0200, Wolfgang Walter wrote:
> >
> > * Works fine, machine is up since 61 minutes.
> 
> Thanks a lot for testing this Wolfgang!

Thanks indeed.

> > * Performance:
> >
> > Routing performance over esp-tunnels seems unchanged here compared to 2.6.25
> > (this was also the case with the "kernel_fpu_begin" patch).
> >
> > tcrypt mode=200 shows exactly the same performance penalty compared to 2.6.25
> > as the "kernel_fpu_begin" patch.
> 
> That's not surprising since tcrypt runs with BH off so it'll
> do pretty much the same thing as before.

Ok. In the real world usage, where we use these instructions both from
process and softirq context, we will probably not see much penality,
as the process context's first access will always endup doing full fp restore
(and also we kick in the context switch FP optimization, which will
proactively restore fp state if we touch FPU in 5 consecutive task slices).

> This also shows that
> reading CR0 doesn't impose any extra overhead compared to what
> was done in kernel_fpu_begin.

As there are no further objections, Herbert/Ingo not sure who among you
will push this patch to Linus tree and  2.6.26 -stable tree aswell.

thanks,
suresh

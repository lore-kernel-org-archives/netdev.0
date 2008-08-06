From: Suresh Siddha <suresh.b.siddha@intel.com>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Wed, 6 Aug 2008 14:21:52 -0700
Message-ID: <20080806212152.GB607@linux-os.sc.intel.com>
References: <200807171653.59177.wolfgang.walter@stwm.de> <200807301411.01622.wolfgang.walter@stwm.de> <20080806103354.GA31623@gondor.apana.org.au> <200808061933.25631.wolfgang.walter@stwm.de> <20080806201401.GA607@linux-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wolfgang Walter <wolfgang.walter@stwm.de>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>, vegard.nossum@gmail.com
To: wolfgang.walter@stwm.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:30295 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764356AbYHFVVy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Aug 2008 17:21:54 -0400
Content-Disposition: inline
In-Reply-To: <20080806201401.GA607@linux-os.sc.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 06, 2008 at 01:14:02PM -0700, Siddha, Suresh B wrote:
> On Wed, Aug 06, 2008 at 10:33:25AM -0700, Wolfgang Walter wrote:
> > Hello Herbert,
> >
> > I think I finally found the problem.
> >
> > Here a short description again: all our routers with a via C3 using padlock for AES-encryption are
> > crashing with 2.6.26 while they work fine with 2.6.25. Not using padlock
> > (i.e. using the i386 assembler version of AES) they just work fine.
> 
> Both the padlock version or asm version don't use FP/math registers, right?
> It is interesting that you don't see the problem with asm version
> but see the problem with padlock version.
> 
> Does disabling CONFIG_PREEMPT in 2.6.26 change anything? And also,
> can you provide the complete kernel log till the point of failure(oops
> that you sent doesn't have the call trace info)

BTW, in one of your oops, I see:

note: cron[1207] exited with preempt_count 268435459

I smell some kind of stack corruption here which is corrupting
thread_info (in the above case preempt_count in the thread_info).

Similarly, if the status field(in thread_info) gets corrupted(setting
TS_USEDFPU) without proper math state allocated(present in thread_struct),
we can end up oops in __switch_to.

But you seem to say, reverting recent fpu patches make the problem go away.
hmm, just wondering if your test kernel (with fpu patches reverted) is stable
enough and don't see other oops/issues?

Recently Vegard also noticed some stack corruptions (in network stack) leading
to similar problems. Not sure if Vegard has root caused his issue. copying him
for his comments.

thanks,
suresh

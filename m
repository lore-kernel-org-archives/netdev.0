From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/2] export cpu_tlbstate to modules
Date: Tue, 11 Aug 2009 01:06:13 +0300
Message-ID: <20090810220613.GA17099@redhat.com>
References: <cover.1249930169.git.mst@redhat.com> <20090810185302.GB13924@redhat.com> <4A80979E.3080204@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:39126 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752374AbZHJWHg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Aug 2009 18:07:36 -0400
Content-Disposition: inline
In-Reply-To: <4A80979E.3080204@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 10, 2009 at 02:56:46PM -0700, H. Peter Anvin wrote:
> On 08/10/2009 11:53 AM, Michael S. Tsirkin wrote:
> > vhost net module wants to do copy to/from user from a kernel thread,
> > which needs switch_mm (like what fs/aio has).
> > export cpu_tlbstate to make this possible
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > ---
> >  arch/x86/mm/tlb.c |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> > 
> > diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
> > index 821e970..e33a5f0 100644
> > --- a/arch/x86/mm/tlb.c
> > +++ b/arch/x86/mm/tlb.c
> > @@ -13,6 +13,7 @@
> >  
> >  DEFINE_PER_CPU_SHARED_ALIGNED(struct tlb_state, cpu_tlbstate)
> >  			= { &init_mm, 0, };
> > +EXPORT_PER_CPU_SYMBOL_GPL(cpu_tlbstate);
> >  
> >  /*
> >   *	Smarter SMP flushing macros.
> 
> Wouldn't it be a *lot* better to move use_mm() from fs/aio.c into common
> code, and export that instead?
> 
> 	-hpa

That's easy too. What would a good place for it be?


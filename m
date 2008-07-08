From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [RFC 08/11] remove CONFIG_KMOD from net
Date: Tue, 8 Jul 2008 21:40:17 +0300
Message-ID: <20080708184017.GD11954@cs181140183.pp.htv.fi>
References: <20080708170015.470877000@sipsolutions.net> <20080708170047.433712000@sipsolutions.net> <20080708183035.GC11954@cs181140183.pp.htv.fi> <1215542220.3670.0.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:42182 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753060AbYGHSlN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 14:41:13 -0400
Content-Disposition: inline
In-Reply-To: <1215542220.3670.0.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 08, 2008 at 08:37:00PM +0200, Johannes Berg wrote:
> On Tue, 2008-07-08 at 21:30 +0300, Adrian Bunk wrote:
> > On Tue, Jul 08, 2008 at 07:00:23PM +0200, Johannes Berg wrote:
> > >...
> > > --- everything.orig/net/core/dev.c	2008-07-08 18:35:53.000000000 +0200
> > > +++ everything/net/core/dev.c	2008-07-08 18:36:06.000000000 +0200
> > > @@ -4639,7 +4639,7 @@ EXPORT_SYMBOL(br_fdb_get_hook);
> > >  EXPORT_SYMBOL(br_fdb_put_hook);
> > >  #endif
> > >  
> > > -#ifdef CONFIG_KMOD
> > > +#ifdef CONFIG_MODULES
> > >  EXPORT_SYMBOL(dev_load);
> > >  #endif
> > >...
> > 
> > You can remove the #ifdef  
> 
> Eh, no. Not unless I also always compile in dev_load, which as of now
> depends on CONFIG_MODULES. In fact, another hunk in this series makes it
> a static inline when CONFIG_MODULES=n so that callers don't need to take
> care of #ifdef'ing it.

Look at include/linux/module.h:

...
#ifdef CONFIG_MODULES
...
#define EXPORT_SYMBOL(sym)                                      \
        __EXPORT_SYMBOL(sym, "")
...
#else /* !CONFIG_MODULES... */
#define EXPORT_SYMBOL(sym)
...

> johannes

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed


From: Adrian Bunk <bunk@stusta.de>
Subject: Re: 2.6.23-rc1: BUG_ON in kmap_atomic_prot()
Date: Thu, 26 Jul 2007 20:07:21 +0200
Message-ID: <20070726180721.GN3572@stusta.de>
References: <20070723204045.GD5755@martell.zuzino.mipt.ru> <20070723210153.GA5753@martell.zuzino.mipt.ru> <20070723141137.171e4ac1.akpm@linux-foundation.org> <alpine.LFD.0.999.0707231415511.3607@woody.linux-foundation.org> <20070724175951.GC6019@stusta.de> <alpine.LFD.0.999.0707241113180.3607@woody.linux-foundation.org> <20070724112843.0cc104c2.akpm@linux-foundation.org> <alpine.LFD.0.999.0707241207290.3607@woody.linux-foundation.org> <20070724194046.GD6019@stusta.de> <alpine.LFD.0.999.0707241246130.3607@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:45768 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932123AbXGZSHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 14:07:49 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0707241246130.3607@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 24, 2007 at 12:48:13PM -0700, Linus Torvalds wrote:
> 
> 
> On Tue, 24 Jul 2007, Adrian Bunk wrote:
> > 
> > > But do we 
> > > care so much that it's worth inlining something like buffered_rmqueue()? 
> > >...
> > 
> > Where is the problem with having buffered_rmqueue() inlined?
> 
> In this case, it was a pain to just even try to find the call chain, or 
> read the asm.

Optimization versus debugging is a common issue...

As I said, it might make sense to disable this optimization depending on 
some debugging option.

> I would encourage lots of kernel hackers to read the assembler code gcc 
> generates. I suspect people being aware of code generation issues (and 
> writing their code with that in mind) is a *much* bigger performance 
> impact than gcc inlining random functions.
> 
> So maybe I'm old-fashioned and crazy, but "readability of the asm result" 
> actually is a worthwhile goal. Not because we care directly, but because 
> I'd like to encourage people to do it, due to the *indirect* benefits.

This would lead to people trying to optimize code for one gcc version - 
and the code might stay this way for 10 years.

People should write readable C code. This also has the best chances of 
resulting in good performance with the next gcc version on the next 
generation hardware.

> 		Linus

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed


From: Adrian Bunk <bunk@stusta.de>
Subject: Re: 2.6.23-rc1: BUG_ON in kmap_atomic_prot()
Date: Tue, 24 Jul 2007 21:40:46 +0200
Message-ID: <20070724194046.GD6019@stusta.de>
References: <20070723190152.GA5755@martell.zuzino.mipt.ru> <20070723132431.42afbae8.akpm@linux-foundation.org> <20070723204045.GD5755@martell.zuzino.mipt.ru> <20070723210153.GA5753@martell.zuzino.mipt.ru> <20070723141137.171e4ac1.akpm@linux-foundation.org> <alpine.LFD.0.999.0707231415511.3607@woody.linux-foundation.org> <20070724175951.GC6019@stusta.de> <alpine.LFD.0.999.0707241113180.3607@woody.linux-foundation.org> <20070724112843.0cc104c2.akpm@linux-foundation.org> <alpine.LFD.0.999.0707241207290.3607@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:43334 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752204AbXGXTlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 15:41:25 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0707241207290.3607@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 24, 2007 at 12:15:48PM -0700, Linus Torvalds wrote:
> 
> 
> On Tue, 24 Jul 2007, Andrew Morton wrote:
> > 
> > fwiw, -fno-inline-functions-called-once (who knew?) takes i386 allnoconfig
> > vmlinux .text from 928360 up to 955362 bytes (27k larger).
> > 
> > A surprisingly large increase - I wonder if it did something dumb.  It
> > appears to still correctly inline those things which we've manually marked
> > inline.  hm.
> 
> I think inlining small enough functions is worth it, and the thing is, the 
> kernel is actually pretty damn good at having lots of small functions. 
> It's one of the few things I really care about from a coding style 
> standpoint.
> 
> So I'm not surprised that "-fno-inline-functions-called-once" makes things 
> larger, because I think it's generally a good idea to inline things that 
> are just called once. But it does make things harder to debug, and the 
> performance advantages become increasingly small for bigger functions.
> 
> And that's a balancing act. Do we care about performance? Yes.

When using CONFIG_CC_OPTIMIZE_FOR_SIZE=y we even actively tell gcc that 
we only care about size and do not care about performance...

> But do we 
> care so much that it's worth inlining something like buffered_rmqueue()? 
>...

Where is the problem with having buffered_rmqueue() inlined?

> 		Linus

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed


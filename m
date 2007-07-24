From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.23-rc1: BUG_ON in kmap_atomic_prot()
Date: Tue, 24 Jul 2007 12:15:48 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0707241207290.3607@woody.linux-foundation.org>
References: <alpine.LFD.0.999.0707221351030.3607@woody.linux-foundation.org>
 <20070723183839.GA5874@martell.zuzino.mipt.ru> <20070723190152.GA5755@martell.zuzino.mipt.ru>
 <20070723132431.42afbae8.akpm@linux-foundation.org>
 <20070723204045.GD5755@martell.zuzino.mipt.ru> <20070723210153.GA5753@martell.zuzino.mipt.ru>
 <20070723141137.171e4ac1.akpm@linux-foundation.org>
 <alpine.LFD.0.999.0707231415511.3607@woody.linux-foundation.org>
 <20070724175951.GC6019@stusta.de> <alpine.LFD.0.999.0707241113180.3607@woody.linux-foundation.org>
 <20070724112843.0cc104c2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Adrian Bunk <bunk@stusta.de>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52113 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754768AbXGXTRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 15:17:03 -0400
In-Reply-To: <20070724112843.0cc104c2.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 24 Jul 2007, Andrew Morton wrote:
> 
> fwiw, -fno-inline-functions-called-once (who knew?) takes i386 allnoconfig
> vmlinux .text from 928360 up to 955362 bytes (27k larger).
> 
> A surprisingly large increase - I wonder if it did something dumb.  It
> appears to still correctly inline those things which we've manually marked
> inline.  hm.

I think inlining small enough functions is worth it, and the thing is, the 
kernel is actually pretty damn good at having lots of small functions. 
It's one of the few things I really care about from a coding style 
standpoint.

So I'm not surprised that "-fno-inline-functions-called-once" makes things 
larger, because I think it's generally a good idea to inline things that 
are just called once. But it does make things harder to debug, and the 
performance advantages become increasingly small for bigger functions.

And that's a balancing act. Do we care about performance? Yes. But do we 
care so much that it's worth inlining something like buffered_rmqueue()? 

So I would not be surprised if "-fno-inline-functions-called-once" will 
disable *all* the inlining heuristics, and say "oh, it's not an inline 
function, and it's only called once, so we won't inline it at all".

So "called once" should probably make the inlining weight bigger (ie 
inline *larger* functions than you would otherwise), it just shouldn't 
make it "infinite". It's not worth it.

		Linus

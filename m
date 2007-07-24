From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23-rc1: BUG_ON in kmap_atomic_prot()
Date: Tue, 24 Jul 2007 11:28:43 -0700
Message-ID: <20070724112843.0cc104c2.akpm@linux-foundation.org>
References: <alpine.LFD.0.999.0707221351030.3607@woody.linux-foundation.org>
	<20070723183839.GA5874@martell.zuzino.mipt.ru>
	<20070723190152.GA5755@martell.zuzino.mipt.ru>
	<20070723132431.42afbae8.akpm@linux-foundation.org>
	<20070723204045.GD5755@martell.zuzino.mipt.ru>
	<20070723210153.GA5753@martell.zuzino.mipt.ru>
	<20070723141137.171e4ac1.akpm@linux-foundation.org>
	<alpine.LFD.0.999.0707231415511.3607@woody.linux-foundation.org>
	<20070724175951.GC6019@stusta.de>
	<alpine.LFD.0.999.0707241113180.3607@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754483AbXGXS3u@vger.kernel.org>
In-Reply-To: <alpine.LFD.0.999.0707241113180.3607@woody.linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Jul 2007 11:14:21 -0700 (PDT)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> 
> 
> On Tue, 24 Jul 2007, Adrian Bunk wrote:
> > 
> > buffered_rmqueue() and prep_new_page() are static functions with only 
> > one caller each, and for the normal non-debug case it's a really nice 
> > optimization to have them inlined automatically.
> 
> I'm not at all sure I agree.
> 
> Inlining big functions doesn't actually tend to generally generate any 
> better code, so if gcc's logic is "single callsite - always inline", then 
> that logic is likely not right.
> 

fwiw, -fno-inline-functions-called-once (who knew?) takes i386 allnoconfig
vmlinux .text from 928360 up to 955362 bytes (27k larger).

A surprisingly large increase - I wonder if it did something dumb.  It
appears to still correctly inline those things which we've manually marked
inline.  hm.

It would be nice to defeat the autoinlining for debug purposes though.

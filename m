From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.23-rc1: BUG_ON in kmap_atomic_prot()
Date: Mon, 23 Jul 2007 14:28:11 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0707231415511.3607@woody.linux-foundation.org>
References: <alpine.LFD.0.999.0707221351030.3607@woody.linux-foundation.org>
 <20070723183839.GA5874@martell.zuzino.mipt.ru> <20070723190152.GA5755@martell.zuzino.mipt.ru>
 <20070723132431.42afbae8.akpm@linux-foundation.org>
 <20070723204045.GD5755@martell.zuzino.mipt.ru> <20070723210153.GA5753@martell.zuzino.mipt.ru>
 <20070723141137.171e4ac1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41298 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752268AbXGWV2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 17:28:47 -0400
In-Reply-To: <20070723141137.171e4ac1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 23 Jul 2007, Andrew Morton wrote:
> 
> It'd be nice to get a clean trace.  Are you able to obtain the full
> trace with CONFIG_FRAME_POINTER=y?

If you are talking about

	http://userweb.kernel.org/~akpm/dsc03659.jpg

then I think that _is_ a full trace. It's certainly not very messy, and it 
seems accurate. It's just that inlining makes it much harder to see the 
call-graphs, but that's what inlining does..

For example, missing from the call graph is

	get_page_from_freelist ->
	  buffered_rmqueue ->		[ missing - inlined ]
	    prep_new_page ->		[ missing - inlined ]
	      prep_zero_page ->		[ missing - inlined ]
		clear_highpage ->	[ missing - inlined ]
		  kmap_atomic ->	[ missing - tailcall ]
		    kmap_atomic_prot

but I'm pretty sure the call trace is good (and I'm also pretty sure gcc 
is overly aggressive at inlining, and that it causes us pain for 
debugging, but whatever)

The earlier part of the trace looks fine too.

The only odd part I see is the existence of "dput()" there, so maybe it's 
not *quite* clean and enabling frame pointers might get rid of a few bogus 
entries, but it looks pretty close to clean.

			Linus

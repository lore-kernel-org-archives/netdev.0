From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: pre-fetching skb for delayed send
Date: Sat, 7 Jul 2012 10:18:08 -0400
Message-ID: <20120707141808.GE19462@kvack.org>
References: <4FF77070.7040705@candelatech.com> <20120706235258.GD19462@kvack.org> <4FF7B7E1.4000602@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:38478 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751104Ab2GGOSJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Jul 2012 10:18:09 -0400
Content-Disposition: inline
In-Reply-To: <4FF7B7E1.4000602@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 06, 2012 at 09:15:29PM -0700, Ben Greear wrote:
> Well, to start with..I at least know the next skb to transmit,
> so I figured I'd prefetch it before starting tx of the current
> skb.

Prefetching data you're just about to immediately access doesn't actually 
help improve performance -- it's better to just access the data.  Prefetching 
subsequent skbs should be of more benefit.

> My question is more basic though:  Given an skb, how do you prefetch
> it...do you just prefetch the skb pointer, or do you need to dig into
> the guts of the skb?

See prefetch.h for details.  Just pass the pointer to the cacheline you want 
to trigger prefetch on to prefetch() or prefetchw(), or use prefetch_range() 
(probably useful for skbs given that they're larger than one cacheline).  
For an skb, you may have to prefetch the frag list as well.

		-ben
-- 
"Thought is the essence of where you are now."

From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 16083] New: swapper: Page allocation failure
Date: Thu, 3 Jun 2010 15:11:22 -0700
Message-ID: <20100603151122.975569b0.akpm@linux-foundation.org>
References: <bug-16083-10286@https.bugzilla.kernel.org/>
	<20100603130235.c372b38f.akpm@linux-foundation.org>
	<1275599603.2533.58.camel@edumazet-laptop>
	<20100603143915.f1b0ba2b.akpm@linux-foundation.org>
	<1275602282.2533.72.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38916 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751510Ab0FCWL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 18:11:26 -0400
In-Reply-To: <1275602282.2533.72.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 03 Jun 2010 23:58:02 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le jeudi 03 juin 2010 __ 14:39 -0700, Andrew Morton a __crit :
> 
> > Well.  The presence of this warning does serve to remind us how sucky
> > e1000[e] is :(
> > 
> > I'm not particularly fussed either way - I'm just wondering if you guys
> > think this thing meets the noise-to-benefit test...
> > 
> 
> Well, in this particular case, I think its a genuine bug in the ipv6
> code, not on the e1000[e] driver :)
> 
> It allocates "a priori" dev->mtu sized skb that are filled by maybe one
> hundred bytes by caller.
> 
> With MTU=9000, this means order-2 allocations. In an ideal world, it
> would be fine, but in practice, we know only fools can trust high order
> allocations.
> 
> Since code is prepared to chain skbs, just make sure we cap allocations
> to smaller units (up to 0xe80 bytes on a 64bit kernel)
> 
> So in this particular case, the bugzilla report can point to a real
> problem in our stack.
> 
> Failed allocations had been silent, we probably would never have
> noticed.
> 
> Hmm...
> 

heh, in that case I guess we should leave it there.

But I do tend to ignore such reports, or fob them off with some
boilerplate.  It was pure luck that the one I chose as an example
happened to be interesting.


From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: [PATCH for 2.6.33] conntrack: restrict runtime hashsize
 modifications
Date: Thu, 04 Feb 2010 15:20:35 -0500
Message-ID: <1265314835.2861.524.camel@tonnant>
References: <20100203203929.GA6168@x200> <4B6AF36A.3050402@trash.net>
	 <4B6AFE22.20304@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>, davem@davemloft.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dallas.jonmasters.org ([72.29.103.172]:49032 "EHLO
	dallas.jonmasters.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756513Ab0BDUVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 15:21:15 -0500
In-Reply-To: <4B6AFE22.20304@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-02-04 at 18:04 +0100, Patrick McHardy wrote:
> Patrick McHardy wrote:
> > Alexey Dobriyan wrote:
> >> Jon Masters correctly points out that conntrack hash sizes
> >> (nf_conntrack_htable_size) are global (not per-netns) and
> >> modifiable at runtime via /sys/module/nf_conntrack/hashsize .
> >>
> >> Steps to reproduce:
> >> 	clone(CLONE_NEWNET)
> >> 	[grow /sys/module/nf_conntrack/hashsize]
> >> 	exit()
> >>
> >> At netns exit we are going to scan random memory for conntracks to be killed.
> >>
> >> Apparently there is a code which deals with hashtable resize for
> >> init_net (and it was there befode netns conntrack code), so prohibit
> >> hashsize modification if there is more than one netns exists.
> >>
> >> To change hashtable sizes, you need to reload module.
> >>
> >> Expectation hashtable size was simply glued to a variable with no code
> >> to rehash expectations, so it was a bug to allow writing to it.
> >> Make "expect_hashsize" readonly.
> >>
> >> This is temporarily until we figure out what to do.
> > 
> > How about alternatively moving nf_conntrack_hsize into the
> > per-namespace struct? It doesn't look more complicated or
> > intrusive and would allow to still change the init_net
> > hashsize. Also seems less hackish :)
> 
> How about this (so far untested) patch? The htable_size is moved into
> the per-namespace struct and initialized from the current (global)
> value of nf_conntrack_htable_size. Changes through sysfs are still
> permitted, but only affect the init namespace and newly created ones.

I moved the random seed into the per-ns context aswell. I think that's
better than having a global one, and you don't need to rehash all.

Jon.



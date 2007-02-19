From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Extensible hashing and RCU
Date: 19 Feb 2007 13:02:44 +0100
Message-ID: <p734ppifj8b.fsf@bingen.suse.de>
References: <20070204074143.26312.qmail@science.horizon.com>
	<Pine.LNX.4.61.0702050952590.26852@localhost.localdomain>
	<20070217131302.GA22732@2ka.mipt.ru> <45D89EFE.4080103@cosmosbay.com>
	<20070218191009.GA28216@2ka.mipt.ru> <45D8B54A.70903@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, akepner@sgi.com,
	linux@horizon.com, davem@davemloft.net, netdev@vger.kernel.org,
	bcrl@linux.intel.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:58259 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932073AbXBSLC5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 06:02:57 -0500
In-Reply-To: <45D8B54A.70903@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <dada1@cosmosbay.com> writes:
> 
> So are you speaking of one memory cache miss per lookup ?

Actually two: if the trie'ing allows RCUing you would save
the spinlock cache line too. This would increase the 
break-even budget for the trie.

> If not, you loose.

It all depends on if the higher levels on the trie are small
enough to be kept in cache. Even with two cache misses it might
still break even, but have better scalability.

Another advantage would be to eliminate the need for large memory
blocks, which cause problems too e.g. on NUMA. It certainly would
save quite some memory if the tree levels are allocated on demand
only. However breaking it up might also cost more TLB misses, 
but those could be eliminated by preallocating the tree in
the same way as the hash today. Don't know if it's needed or not.

I guess someone needs to code it up and try it.

-Andi

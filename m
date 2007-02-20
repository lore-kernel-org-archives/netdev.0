From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 14:45:35 +0300
Message-ID: <20070220114535.GB27069@2ka.mipt.ru>
References: <20070204074143.26312.qmail@science.horizon.com> <200702201209.52388.dada1@cosmosbay.com> <20070220112902.GB665@2ka.mipt.ru> <200702201235.00107.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: akepner@sgi.com, linux@horizon.com, davem@davemloft.net,
	netdev@vger.kernel.org, bcrl@kvack.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:46568 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932902AbXBTLq7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 06:46:59 -0500
Content-Disposition: inline
In-Reply-To: <200702201235.00107.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 12:34:59PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> > Getting into account that network stack with NAPI schedules several
> > packets to be queued into socket and all that happens without any
> > infuence from userspace, trie/tree wins again in that regard that
> > majority of the tree will be in the cache already.
> 
> Nope, you receive 100 packets for 100 different flows. Only the code may be in 
> cache (minus for the first packet), and the very top of the tree...
> 
> Forget cache. Forget it.

First packet populates half of the top of the tree/trie to get to the
bottom - another one goes to completely different location, but it still
need to go through some of the just populated entries - it is a
tree/trie nature - probability of a hit decreases two times in each
level (for binary tree, for trie is is very different) until first 'miss', 
but it is still non zero.

But generally I afgree that talking about caches can only be valid when
all other issues are resolved completely. So, we need a patch.

-- 
	Evgeniy Polyakov

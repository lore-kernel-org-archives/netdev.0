From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 14:29:02 +0300
Message-ID: <20070220112902.GB665@2ka.mipt.ru>
References: <20070204074143.26312.qmail@science.horizon.com> <200702201104.16200.dada1@cosmosbay.com> <20070220104418.GA5262@2ka.mipt.ru> <200702201209.52388.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: akepner@sgi.com, linux@horizon.com, davem@davemloft.net,
	netdev@vger.kernel.org, bcrl@kvack.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:33684 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964807AbXBTLaM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 06:30:12 -0500
Content-Disposition: inline
In-Reply-To: <200702201209.52388.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 12:09:51PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> If we want to optimize tcp, we should reorder fields to reduce number of cache 
> lines, not change algos. struct sock fields are currently placed to reduce 
> holes, while they should be grouped by related fields sharing cache lines.

Getting into account that network stack with NAPI schedules several
packets to be queued into socket and all that happens without any
infuence from userspace, trie/tree wins again in that regard that
majority of the tree will be in the cache already.

Hash table has its fast access only in theory, practice adds caches,
NAPI and a lot of other stuff. Even simple test (maybe broken, but it
is equally broken for both trie and hash, even worse for trie))
whows that hash table does not behave as good as expected and close to
trie.

I'm going back to drawing board to design simple trie algo/patch
suitable for hash table selection replacement, so that we would test it
in a real life examples.

-- 
	Evgeniy Polyakov

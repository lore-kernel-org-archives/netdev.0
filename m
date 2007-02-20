From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 12:34:59 +0100
Message-ID: <200702201235.00107.dada1@cosmosbay.com>
References: <20070204074143.26312.qmail@science.horizon.com> <200702201209.52388.dada1@cosmosbay.com> <20070220112902.GB665@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: akepner@sgi.com, linux@horizon.com, davem@davemloft.net,
	netdev@vger.kernel.org, bcrl@kvack.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:39596 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932892AbXBTLfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 06:35:09 -0500
In-Reply-To: <20070220112902.GB665@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 20 February 2007 12:29, Evgeniy Polyakov wrote:
> On Tue, Feb 20, 2007 at 12:09:51PM +0100, Eric Dumazet (dada1@cosmosbay.com) 
wrote:
> > If we want to optimize tcp, we should reorder fields to reduce number of
> > cache lines, not change algos. struct sock fields are currently placed to
> > reduce holes, while they should be grouped by related fields sharing
> > cache lines.
>
> Getting into account that network stack with NAPI schedules several
> packets to be queued into socket and all that happens without any
> infuence from userspace, trie/tree wins again in that regard that
> majority of the tree will be in the cache already.

Nope, you receive 100 packets for 100 different flows. Only the code may be in 
cache (minus for the first packet), and the very top of the tree...

Forget cache. Forget it.

>
> Hash table has its fast access only in theory, practice adds caches,
> NAPI and a lot of other stuff. Even simple test (maybe broken, but it
> is equally broken for both trie and hash, even worse for trie))
> whows that hash table does not behave as good as expected and close to
> trie.
>
> I'm going back to drawing board to design simple trie algo/patch
> suitable for hash table selection replacement, so that we would test it
> in a real life examples.

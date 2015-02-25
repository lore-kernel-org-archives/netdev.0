From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net 2/2] rhashtable: remove indirection for grow/shrink
 decision functions
Date: Wed, 25 Feb 2015 20:10:08 +0000
Message-ID: <20150225201007.GF1706@acer.localdomain>
References: <cover.1424877322.git.daniel@iogearbox.net>
 <cd3e70163920753c7f1a492e6df253cff9b1b080.1424877322.git.daniel@iogearbox.net>
 <063D6719AE5E284EB5DD2968C1650D6D1CAED36D@AcuExch.aculab.com>
 <54EDEE55.8050605@iogearbox.net>
 <063D6719AE5E284EB5DD2968C1650D6D1CAED3A1@AcuExch.aculab.com>
 <54EDF4DD.1060709@iogearbox.net>
 <1424886096.5565.104.camel@edumazet-glaptop2.roam.corp.google.com>
 <54EE1AC8.6060206@iogearbox.net>
 <1424893929.5565.122.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Laight <David.Laight@ACULAB.COM>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57792 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752644AbbBYUKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 15:10:15 -0500
Content-Disposition: inline
In-Reply-To: <1424893929.5565.122.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25.02, Eric Dumazet wrote:
> On Wed, 2015-02-25 at 19:56 +0100, Daniel Borkmann wrote:
> > On 02/25/2015 06:41 PM, Eric Dumazet wrote:
> > ...
> > > There is no need to track number of elements, using either an atomic_t
> > > or percpu_counter. This adds unnecessary burden.
> > >
> > > 1) Automatic shrinking is a non issue. This will free very little
> > > memory, compared to previous peak usage (including objects put in
> > > rhashtable). If hash grown to a certain point, it's likely it will grow
> > > again later.
> > 
> > So you are saying that shrinking is most likely a rather undesirable
> > use-case in rhashtable?
> 
> Main point of rhashtable is to start with a small/reasonable size,
> and only big consumers need to _expand_ the table.
> 
> Like, instead of having 512000 slots in TCP hash table, start with a
> 2^10 size.
> 
> Like my laptop currently has :
> 
> TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
> 
> Which is kind of ridiculous....
> 
> But if any workload had to grow the table to 2^20 slots, we had to
> consume GB of memory anyway to hold sockets and everything.
> 
> Trying to shrink is simply not worth it, unless you expect your host
> never reboots and you desperately need back these 8 MBytes of memory.

That may be true in the TCP case, but for not for nftables. We might
have many sets and, especially when used to represent more complicated
classification algorithms, their size might change by a lot.

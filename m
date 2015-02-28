From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net 2/2] rhashtable: remove indirection for grow/shrink
 decision functions
Date: Sat, 28 Feb 2015 00:48:40 +0000
Message-ID: <20150228004840.GA18513@acer.localdomain>
References: <54EDF4DD.1060709@iogearbox.net>
 <1424886096.5565.104.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150226100235.GA16032@casper.infradead.org>
 <20150227.173011.720468189098021308.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, eric.dumazet@gmail.com, daniel@iogearbox.net,
	David.Laight@ACULAB.COM, pablo@netfilter.org, johunt@akamai.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45458 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752592AbbB1Asq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 19:48:46 -0500
Content-Disposition: inline
In-Reply-To: <20150227.173011.720468189098021308.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27.02, David Miller wrote:
> From: "tgraf@suug.ch" <tgraf@suug.ch>
> Date: Thu, 26 Feb 2015 10:02:35 +0000
> 
> > I just want to point out here that TCP is not the only future
> > use case. The station table for mac80211 has recently been
> > converted. We need to keep all of them on the radar.
> 
> Just wanted to note in passing that I wonder how legal
> net/core/neighbour.c:neigh_hash_grow() is.  It's growing an RCU
> hashtable without using rhashtable. :-)

I would like to note that it seem premature to convert all these
users without having the fundamental problems solved, specifically
the unbounded growing hash chains with async resizing.

It seems to me that we have enough use cases right now that problems
have become quite visible, and until we're sure they're actually
solvable for all these different use cases I'd advocate for not
moving more subsystems to use this.

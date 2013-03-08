From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: use stronger hash for reassembly queue hash table
Date: Fri, 8 Mar 2013 21:53:19 +0100
Message-ID: <20130308205319.GG28531@order.stressinduktion.org>
References: <20130307214211.GP7941@order.stressinduktion.org> <20130308055718.GA28531@order.stressinduktion.org> <20130308130433.GB28531@order.stressinduktion.org> <1362754386.15793.226.camel@edumazet-glaptop> <20130308150831.GD28531@order.stressinduktion.org> <1362756219.15793.240.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52203 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754610Ab3CHUxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 15:53:20 -0500
Content-Disposition: inline
In-Reply-To: <1362756219.15793.240.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 08, 2013 at 07:23:39AM -0800, Eric Dumazet wrote:
> On Fri, 2013-03-08 at 16:08 +0100, Hannes Frederic Sowa wrote:
> > On Fri, Mar 08, 2013 at 06:53:06AM -0800, Eric Dumazet wrote:
> > > No matter how you hash, a hacker can easily fill your defrag unit with
> > > not complete datagrams, so what's the point ?
> > 
> > I want to harden reassembly logic against all fragments being put in
> > the same hash bucket because of malicious traffic and thus creating
> > long list traversals in the fragment queue hash table.
> 
> Note that the long traversal was a real issue with TCP (thats why I
> introduced ipv6_addr_jhash()), as a single ehash slot could contains
> thousand of sockets.
> 
> But with fragments, we should just limit the depth of any particular
> slot, and drop above a particular threshold.
> 
> reassembly is a best effort mechanism, better make sure it doesnt use
> all our cpu cycles.

On my VM I counted 17500 iterations in one hash bucket and maxing out
one CPU until I got rcu stalls and NMIs. In comparison: If I use the
old hasing code I have max iterations of 370 and don't expirience any
rcu stalls or NMIs (seems to be around 17500/64+-epsilon).

I have not yet drawn my conclusion on this, yet, but I agree some list
length limiting code would be useful independent of the hash function.

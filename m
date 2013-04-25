From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: RE: [net-next PATCH 0/4] net: frag patchset for fixing LRU
 scalabilityissue
Date: Thu, 25 Apr 2013 13:39:55 +0200
Message-ID: <1366889995.26911.555.camel@localhost>
References: <20130424154624.16883.40974.stgit@dragon>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B71F9@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39823 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756471Ab3DYMmx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 08:42:53 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B71F9@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-24 at 17:21 +0100, David Laight wrote:
> > I have dropped the idea of doing "direct hash cleaning".  Instead I
> > have simply choosen to solve the global LRU list problem, by making
> > the LRU list be per CPU.
> 
> How can a per-cpu LRU list work?
> I see two immediate problems:
> - Ensuring the normal 'allocate' and 'free' are always done
>   on the same cpu (free will need to remove items from any
>   LRU list).
> - Ensuring that there all the items aren't on the LRU lists
>   of other cpus - meaning one can't be allocated.
> 
> The only way this could work is if the allocation limit
> is also per-cpu and you can guarantee that the alloc and
> free for any given item will always happen on the same cpu.
> 
> (alloc as in 'add to LRU list, free as in 'remove from LRU list).

Please read patch-04.

I've added "cpu_alloc" to record the CPU were the first fragment got
allocated.  After which all frags gets accounted to that CPU,
add/remove/timeout etc.

--Jesper

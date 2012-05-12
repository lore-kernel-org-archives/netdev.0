From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] codel: use Newton method instead of sqrt()
 and divides
Date: Sat, 12 May 2012 15:52:59 -0400 (EDT)
Message-ID: <20120512.155259.1178343836887150194.davem@davemloft.net>
References: <1336829533.31653.1108.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave.taht@bufferbloat.net, netdev@vger.kernel.org,
	nichols@pollere.com, van@pollere.net, codel@lists.bufferbloat.net,
	ycheng@google.com, mattmathis@google.com, therbert@google.com,
	shemminger@vyatta.com, nanditad@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44109 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530Ab2ELTzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2012 15:55:07 -0400
In-Reply-To: <1336829533.31653.1108.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 12 May 2012 15:32:13 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> As Van pointed out, interval/sqrt(count) can be implemented using
> multiplies only.
> 
> http://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Iterative_methods_for_reciprocal_square_roots
> 
> This patch implements the Newton method and reciprocal divide.
> 
> Total cost is 15 cycles instead of 120 on my Corei5 machine (64bit
> kernel).
> 
> There is a small 'error' for count values < 5, but we don't really care.
> 
> I reuse a hole in struct codel_vars :
>  - pack the dropping boolean into one bit
>  - use 31bit to store the reciprocal value of sqrt(count).
> 
> Suggested-by: Van Jacobson <van@pollere.net>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied but I never like that bitfield sharing for real integers.

GCC makes a complete mess of it as it extracts and inserts the
integer value into that bit field.  You are guarenteed to get
better code if you do this by hand in a full u32.

Either that or just bite the bullet and use a completely seperate
field, maybe we'll need more boolean states later.

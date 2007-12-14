From: David Miller <davem@davemloft.net>
Subject: Re: [NETFILTER] xt_hashlimit : speedups hash_dst()
Date: Fri, 14 Dec 2007 10:30:31 -0800 (PST)
Message-ID: <20071214.103031.39124025.davem@davemloft.net>
References: <4762646B.30207@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42527
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755534AbXLNSac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 13:30:32 -0500
In-Reply-To: <4762646B.30207@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 14 Dec 2007 12:09:31 +0100

> 1) Using jhash2() instead of jhash() is a litle bit faster if applicable.
> 
> 2) Thanks to jhash, hash value uses full 32 bits.
>     Instead of returning hash % size (implying a divide)
>     we return the high 32 bits of the (hash * size) that will
>     give results between [0 and size-1] and same hash distribution.
> 
>    On most cpus, a multiply is less expensive than a divide, by an order
>    of magnitude.
>   
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

As a side note, Jenkins performs nearly optimally (unlike
most traditional hash functions) with power of two hash
table sizes.

Using a pow2 hash table size would completely obviate the
issues solved by #2.

I don't know if that is feasible here in xt_hashlimit, but
if it is that is how we should solve this expensive
modulo.

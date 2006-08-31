From: David Miller <davem@davemloft.net>
Subject: Re: [TCP]: Fix rcv mss estimate for LRO
Date: Thu, 31 Aug 2006 15:10:37 -0700 (PDT)
Message-ID: <20060831.151037.21907191.davem@davemloft.net>
References: <20060831131833.GA1903@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20669
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964789AbWHaWKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 18:10:32 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060831131833.GA1903@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 31 Aug 2006 23:18:33 +1000

> The Xen performance problem turned out to be something else altogether.
> It was an incorrect rcv mss estimate which leads to delayed acks.  So
> it's not a bug in Linux yet :) However, since we need this for LRO as
> well, here's a patch for net-2.6.19.

Good spotting.

> [TCP]: Fix rcv mss estimate for LRO
> 
> By passing a Linux-generated TSO packet straight back into Linux, Xen
> becomes our first LRO user :) Unfortunately, there is at least one spot
> in our stack that needs to be changed to cope with this.
> 
> The receive MSS estimate is computed from the raw packet size.  This is
> broken if the packet is GSO/LRO.  Fortunately the real MSS can be found
> in gso_size so we simply need to use that if it is non-zero.
> 
> Real LRO NICs should of course set the gso_size field in future.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Ok, I'll put this into net-2.6.19, but I think it deserves
serious consideration for 2.6.18 because the S2IO driver
does implement HW LRO and it is almost certainly getting
bitten by this issue since I do not see that driver setting
gso_size, and perhaps the current S2io firmware implementing
this cannot provide the MSS value needed.

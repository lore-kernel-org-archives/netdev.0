From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/3] myri10ge Large Receive Offload
Date: Thu, 28 Sep 2006 00:27:48 -0400
Message-ID: <451B4F44.60204@garzik.org>
References: <451B0541.1030208@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49366 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751334AbWI1E1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 00:27:53 -0400
To: Brice Goglin <brice@myri.com>
In-Reply-To: <451B0541.1030208@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> This is a complete rework of the myri10ge receive path. The first
> patch converts skb allocation to use physical pages. The second one
> adds a software implementation of Large Receive Offload. The third
> one updates the driver version to 1.1.0.
> 
> The complete driver code in our CVS actually also supports high-order
> allocations instead of single physical pages since it significantly
> increase the performance. Order=2 allows us to receive standard frames
> at line rate even on low-end hardware such as an AMD Athlon(tm) 64 X2
> Dual Core Processor 3800+ (2.0GHz). Some customer might not care a lot
> about memory fragmentation if the performance is better.
> 
> But, since high-order allocations are generally considered a bad idea,
> we do not include the relevant code in the following patch for inclusion
> in Linux. Here, we simply pass order=0 to all page allocation routines.
> If necessary, I could drop the remaining reference to high-order
> (especially replace alloc_pages() with alloc_page()) but I'd rather
> keep it as is.
> 
> If high-order allocations are ever considered OK under some circum-
> stances, we could send an additional patch (a module parameter would
> be used to switch from single physical pages to high-order pages).

As Herbert's already done, I would rather let the net core people 
comment on this.  The code implementation doesn't look scary, but we may 
want to be smarter about this in the core net stack, rather than 
implementing it inside multiple drivers.

	Jeff




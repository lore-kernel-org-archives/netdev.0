From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.21 -> 2.6.22 & 2.6.23-rc8 performance regression
Date: Mon, 01 Oct 2007 13:57:10 -0700 (PDT)
Message-ID: <20071001.135710.99174896.davem@davemloft.net>
References: <20070930223503.M8966@nuclearcat.com>
	<47008CB0.7010808@cosmosbay.com>
	<4701541B.70108@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nuclearcat@nuclearcat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54561
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752628AbXJAU5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 16:57:10 -0400
In-Reply-To: <4701541B.70108@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 01 Oct 2007 22:10:03 +0200

> So maybe the following patch is necessary...
> 
> I believe IPV6 & DCCP are immune to this problem.
> 
> Thanks again Denys for spotting this.
> 
> Eric
> 
> [PATCH] TCP : secure_tcp_sequence_number() should not use a too fast clock
> 
> TCP V4 sequence numbers are 32bits, and RFC 793 assumed a 250 KHz clock.
> In order to follow network speed increase, we can use a faster clock, but
> we should limit this clock so that the delay between two rollovers is
> greater than MSL (TCP Maximum Segment Lifetime : 2 minutes)
> 
> Choosing a 64 nsec clock should be OK, since the rollovers occur every
> 274 seconds.
> 
> Problem spotted by Denys Fedoryshchenko
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Thanks a lot Eric for bringing closure to this.

I'll apply this and add a reference in the commit message to the
changeset that introduced this problem, since it might help
others who look at this.

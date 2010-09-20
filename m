From: Nick Bowler <nbowler@elliptictech.com>
Subject: Re: Regression, bisected: reference leak with IPSec since ~2.6.31
Date: Mon, 20 Sep 2010 17:23:04 -0400
Message-ID: <20100920212304.GA2042@elliptictech.com>
References: <20100920174443.GA5515@elliptictech.com>
 <1285006844.2323.17.camel@edumazet-laptop>
 <20100920195256.GA14330@elliptictech.com>
 <20100920.130047.124017922.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100920.130047.124017922.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2010-09-20 13:00 -0700, David Miller wrote:
> From: Nick Bowler <nbowler@elliptictech.com>
> > The long answer, however, is interesting: With latest Linus' git, the
> > references are cleaned up much later than I would expect.
[...]
> This is because we actually cache IPSEC routes correctly, previously
> we'd create a new routing cache entry every time a lookup happened.

But this means that the SAs, including their cryptographic keys, are
kept in memory indefinitely after the SAD/SPD entries are destroyed.
Why aren't the cache entries invalidated when this occurs?

This also makes it extremely difficult to unload the xfrm modules,
something we often need to do during testing, as references to them
are held indefinitely.

-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)

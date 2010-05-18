From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [0/4] Fix addrconf race conditions
Date: Wed, 19 May 2010 08:35:42 +1000
Message-ID: <20100518223542.GA17320@gondor.apana.org.au>
References: <20100423150540.GA26611@gondor.apana.org.au> <20100518110243.GA7750@gondor.apana.org.au> <20100518102550.65ad3fdd@nehalam> <20100518.152759.218054760.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, jbohac@suse.cz, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:37046 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751742Ab0ERWfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 18:35:54 -0400
Content-Disposition: inline
In-Reply-To: <20100518.152759.218054760.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 18, 2010 at 03:27:59PM -0700, David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Tue, 18 May 2010 10:25:50 -0700
> 
> > I wonder if so many fine grained locks are really necessary at
> > all.  Everything but timers looks like it is under RTNL mutex
> > already.
> 
> I can't see any reasonable alternative, and it took weeks to get
> a fix at all.

Right, the issue is with forcing an immediate effect after an
NDISC packet triggers an address addition/deletion.

>From what I can gather, the hard case was with NDISC address
addition with DAD disabled.  That is, you have an NDISC packet
that causes an addition followed immediately by a packet destined
(or otherwise relying on) that new address.  In that case, we
simply have no chance of using the RTNL.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH linux-2.6 v2] IPv6: Create temporary address if none
 exists.
Date: Tue, 28 Sep 2010 22:25:10 -0700 (PDT)
Message-ID: <20100928.222510.71109554.davem@davemloft.net>
References: <20100927170430.GA7106@adams.ccsl.carleton.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, shemminger@vyatta.com,
	eric.dumazet@gmail.com, herbert@gondor.apana.org.au,
	ebiederm@xmission.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: gwurster@scs.carleton.ca
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100927170430.GA7106@adams.ccsl.carleton.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Glenn Wurster <gwurster@scs.carleton.ca>
Date: Mon, 27 Sep 2010 13:04:30 -0400

> If privacy extentions are enabled, but no current temporary address exists,
> then create one when we get a router advertisement.
> 
> Version 2, now with 100% fewer line wraps.  Thanks to David Miller for
> pointing out the line wrapping issue.
> 
> Signed-off-by: Glenn Wurster <gwurster@scs.carleton.ca>

The existing code is correct from what I can tell.

Variable "create" is true when "ifp == NULL" and "valid_lft != 0"

And RFC 3041 explicitly states in section 3.3:

	When a new public address is created as described in [ADDRCONF]
	(because the prefix advertised does not match the prefix of any
	address already assigned to the interface, and Valid Lifetime
	in the option is not zero), also create a new temporary address.

Your patch is going to cause us to create a temporary address even
when valid_lft is zero, which the RFC says we should not do.

That goes against what the RFC tells us to do, so I can only conclude
that your patch is not correct.

I'm not applying this, sorry.

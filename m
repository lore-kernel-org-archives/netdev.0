From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v2 PATCH 7/10] rhashtable: Disable automatic shrinking
Date: Mon, 23 Mar 2015 08:33:19 +0000
Message-ID: <20150323083319.GB16023@casper.infradead.org>
References: <20150322080330.GA3416@gondor.apana.org.au>
 <E1YZard-0000wE-Se@gondolin.me.apana.org.au>
 <20150322121755.GH1185@casper.infradead.org>
 <20150323000954.GB9507@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54516 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbbCWIdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 04:33:24 -0400
Content-Disposition: inline
In-Reply-To: <20150323000954.GB9507@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/23/15 at 11:09am, Herbert Xu wrote:
> On Sun, Mar 22, 2015 at 12:17:55PM +0000, Thomas Graf wrote:
> > 
> > This is misleading. I agree that unconditional shrinking is dangerous.
> > Shrinking was an optional feature disabled by default before. The
> 
> How was shrinking disabled before? AFAICS it always kicked in at
> 30%.

Before Daniel removed the indirection due to all callers enabling
shrinking by default ;-) It was clear that some future users
eventually would not want shrinking and thus require a conditional.

> > inlining enabled it by default for all users. What is the benefit of
> > requiring this logic outside of rhashtable over just adding a flag to
> > enable shrinking at 30% utilization?
> 
> That would be adding an extra branch on the fast-path for an
> operation which almost nobody needs.

I don't get why almost nobody would want shrinking. I agree that for
tables like TCP hash tables, once you have grown you want to keep that
table size because the load is likely to come back. But we will also
have lots of users such as the Netlink socket with a table per protocol
where not shrinking results in giving the user the ability to waste
memory indefinitely for no gain.

I'm not claiming you always want shrinking but what gain is there by
removing integrated support? Can you show numbers that the additional
branch actually hurts?

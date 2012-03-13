From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Namespaces and inetpeer
Date: Tue, 13 Mar 2012 10:41:11 +0100
Message-ID: <20120313094111.GN15404@secunet.com>
References: <20120310132529.GA3631@gondor.apana.org.au>
 <20120312085756.GL15404@secunet.com>
 <20120312121130.GA17547@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:56251 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759774Ab2CMJl1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2012 05:41:27 -0400
Content-Disposition: inline
In-Reply-To: <20120312121130.GA17547@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 12, 2012 at 11:11:30PM +1100, Herbert Xu wrote:
> On Mon, Mar 12, 2012 at 09:57:56AM +0100, Steffen Klassert wrote:
> >
> > Actually, it would be nice if we could have an inetpeer base per
> > fib table. This would imply namespace awareness and it would
> > handle the problem when we have mulitiple routes (with different
> > metrics etc.) to the same ip address on policy routing.
> 
> How would you handle incoming ICMP need-to-frag messages?
> 

I thought we could do a (reverse) lookup for the fib table
on incomming ICMP messages. While this would probaply work
if the source address etc. was used as the lookup key for the
initial fib table lookup, this is a real problem if a netfilter
mark was used as the lookup key.

While looking closer at this issue, I've got some doubts if we
ever handled the metrics correct when we choose the fib tables
based on marks. And indeed, in this case it never really worked.
When we updated the mtu based on an incomming ICMP from a certain
IP address, all routes to this ip address used this updated mtu.

If we choose the fib table based on source addresses, it worked as
long as we cached the metrics in the routing cache entries.
While we probaply could fix this case, I don't see how we can handle
the metrics when the initial fib table lookup is base on marks.

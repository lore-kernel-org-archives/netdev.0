From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH net-next v2] tcp: metrics: Handle v6/v4-mapped sockets in
 tcp-metrics
Date: Fri, 24 Jan 2014 00:26:38 +0100
Message-ID: <20140123232638.GA5520@cpaasch-mac>
References: <1390395524-27930-1-git-send-email-christoph.paasch@uclouvain.be>
 <20140123.124926.313254281273203545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:47423 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966AbaAWX0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 18:26:46 -0500
Content-Disposition: inline
In-Reply-To: <20140123.124926.313254281273203545.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/01/14 - 12:49:26, David Miller wrote:
> From: Christoph Paasch <christoph.paasch@uclouvain.be>
> Date: Wed, 22 Jan 2014 13:58:44 +0100
> 
> > A socket may be v6/v4-mapped. In that case sk->sk_family is AF_INET6,
> > but the IP being used is actually an IPv4-address.
> > Current's tcp-metrics will thus represent it as an IPv6-address:
> > 
> > root@server:~# ip tcp_metrics
> > ::ffff:10.1.1.2 age 22.920sec rtt 18750us rttvar 15000us cwnd 10
> > 10.1.1.2 age 47.970sec rtt 16250us rttvar 10000us cwnd 10
> > 
> > This patch modifies the tcp-metrics so that they are able to handle the
> > v6/v4-mapped sockets correctly.
> > 
> > Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> 
> Applied, but I guess you didn't look at the build warnings, nor thoroughly
> test this:
> 
> > +	else if (sk->sk_family = AF_INET6) {
> 
> That's an assignment, not a straight test, and the compiler warns
> about it.
> 
> I fixed it when I applied this, but please don't be so sloppy in the
> future.

Ouch, I'm really sorry. Thanks for fixing it.

I did actually test it and it worked, because if sk_family is not AF_INET
then it can only be AF_INET6 and so the assignment won't change sk_family
and the if condition will be true.

Anyways, I will pay more attention in the future.

Thanks!

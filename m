From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] tcp: metrics: Handle v6/v4-mapped sockets
 in tcp-metrics
Date: Thu, 23 Jan 2014 12:49:26 -0800 (PST)
Message-ID: <20140123.124926.313254281273203545.davem@davemloft.net>
References: <1390395524-27930-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60063 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331AbaAWUt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 15:49:26 -0500
In-Reply-To: <1390395524-27930-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Wed, 22 Jan 2014 13:58:44 +0100

> A socket may be v6/v4-mapped. In that case sk->sk_family is AF_INET6,
> but the IP being used is actually an IPv4-address.
> Current's tcp-metrics will thus represent it as an IPv6-address:
> 
> root@server:~# ip tcp_metrics
> ::ffff:10.1.1.2 age 22.920sec rtt 18750us rttvar 15000us cwnd 10
> 10.1.1.2 age 47.970sec rtt 16250us rttvar 10000us cwnd 10
> 
> This patch modifies the tcp-metrics so that they are able to handle the
> v6/v4-mapped sockets correctly.
> 
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Applied, but I guess you didn't look at the build warnings, nor thoroughly
test this:

> +	else if (sk->sk_family = AF_INET6) {

That's an assignment, not a straight test, and the compiler warns
about it.

I fixed it when I applied this, but please don't be so sloppy in the
future.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: provide SYN headers for passive
 connections
Date: Tue, 05 May 2015 16:05:35 -0400 (EDT)
Message-ID: <20150505.160535.1034497188259706110.davem@davemloft.net>
References: <20150501202908.GC6113@akamai.com>
	<1430512894.3711.140.camel@edumazet-glaptop2.roam.corp.google.com>
	<1430714086.3711.165.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: emunson@akamai.com, tom@herbertland.com, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56079 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030908AbbEEUFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 16:05:40 -0400
In-Reply-To: <1430714086.3711.165.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 03 May 2015 21:34:46 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> This patch allows a server application to get the TCP SYN headers for
> its passive connections.  This is useful if the server is doing
> fingerprinting of clients based on SYN packet contents.
> 
> Two socket options are added: TCP_SAVE_SYN and TCP_SAVED_SYN.
> 
> The first is used on a socket to enable saving the SYN headers
> for child connections. This can be set before or after the listen()
> call.
> 
> The latter is used to retrieve the SYN headers for passive connections,
> if the parent listener has enabled TCP_SAVE_SYN.
> 
> TCP_SAVED_SYN is read once, it frees the saved SYN headers.
> 
> The data returned in TCP_SAVED_SYN are network (IPv4/IPv6) and TCP
> headers.
> 
> Original patch was written by Tom Herbert, I changed it to not hold
> a full skb (and associated dst and conntracking reference).
> 
> We have used such patch for about 3 years at Google.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, but I think you should give maybe a little bit more thought
into the behavior when a not-large-enough buffer is supplied by the
user.

Since we're talking about things on the order of 60 bytes or so at
most, it seems clear to me that signalling an error is probably the
most advisable thing to do in this situation.

Maybe you could signal an error, yet write the actual length to
"optlen".  That way the user can figure out how much they need.  Then
they at least would have the option of retrying with a larger buffer.

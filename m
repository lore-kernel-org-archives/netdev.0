From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: tcp: move to timewait when receiving data
 post active-close
Date: Thu, 19 Nov 2015 12:11:01 -0500 (EST)
Message-ID: <20151119.121101.531386600459835141.davem@davemloft.net>
References: <1447860480.22599.151.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151118153621.GA5860@breakpoint.cc>
	<1447861591.22599.157.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org, marcelo.leitner@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44243 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752897AbbKSRLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 12:11:03 -0500
In-Reply-To: <1447861591.22599.157.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Nov 2015 07:46:31 -0800

> Anyway, having a TIMEWAIT setup after sending a RST makes little
> sense to me.
> 
> When a RST packet is sent, the remote peer will forget everything about
> this previous connection, and another connect() might reuse the tuple
> and I do not think we should forbid this. Normal PAWS checks were
> invented for a good reason.
> 
> RFC 1122, 4.2.2.13 can be interpreted in very different ways.

I think it is clear that once RST is emitted, that connection ID
no longer exists, on both ends.

Sender of RST must not have that matching state, and receiver of
RST must tear things down.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] rps: Inspect GRE encapsulated packets to get flow
 hash
Date: Thu, 19 May 2011 15:39:16 -0400 (EDT)
Message-ID: <20110519.153916.2250094502232694032.davem@davemloft.net>
References: <alpine.DEB.2.00.1105190827420.12804@pokey.mtv.corp.google.com>
	<1305821795.3028.82.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44609 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934417Ab1ESTjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 15:39:21 -0400
In-Reply-To: <1305821795.3028.82.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 May 2011 18:16:35 +0200

> For sure it helps if this machine is the final host for these packets.
> 
> If I am a firewall or router [and not looking into GRE packets], maybe I
> dont want to spread all packets received on a tunnel to several cpus and
> reorder them when forwarded.

Maybe is the operative word here.

Unless you look inside of the tunnel, you may not have any entropy
at all for packet steering and that seems to be what Tom is trying
to attack here.

Also, if we are properly keying the inner-flow, reordering isn't an
issue.  Actual flows will not be reordered.

> Maybe we need to add a table, so that upper layer (GRE or IPIP tunnels)
> can instruct __skb_get_rxhash() that we want to deep inspect packets.

Keep in mind that we have essentially already established that the
goal of this code is to obtain as much hash steering entropy as
possible without causing the reordering of traffic within a
TCP/UDP/SCTP/etc. connection.

And Tom's changes are consistent with those goals.

If we want to start having knobs and ways to change this policy that
is a totally seperate discussion from whether Tom's changes are
correct and ready to be applied, which I think they essentially are.

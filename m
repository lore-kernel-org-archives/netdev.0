From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net] ip: make IP identifiers less predictable
Date: Mon, 28 Jul 2014 18:47:00 -0700 (PDT)
Message-ID: <20140728.184700.953380868397707799.davem@davemloft.net>
References: <1406189276.3363.63.camel@edumazet-glaptop2.roam.corp.google.com>
	<1406317840.3363.106.camel@edumazet-glaptop2.roam.corp.google.com>
	<1406357890.12728.9.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffk@cs.unm.edu, crandall@cs.unm.edu,
	torvalds@linux-foundation.org, w@1wt.eu, security@kernel.org,
	hannes@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35494 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbaG2BrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 21:47:01 -0400
In-Reply-To: <1406357890.12728.9.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 26 Jul 2014 08:58:10 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> In "Counting Packets Sent Between Arbitrary Internet Hosts", Jeffrey and
> Jedidiah describe ways exploiting linux IP identifier generation to
> infer whether two machines are exchanging packets.
> 
> With commit 73f156a6e8c1 ("inetpeer: get rid of ip_id_count"), we
> changed IP id generation, but this does not really prevent this
> side-channel technique.
> 
> This patch adds a random amount of perturbation so that IP identifiers
> for a given destination [1] are no longer monotonically increasing after
> an idle period.
> 
> Note that prandom_u32_max(1) returns 0, so if generator is used at most
> once per jiffy, this patch inserts no hole in the ID suite and do not
> increase collision probability.
> 
> This is jiffies based, so in the worst case (HZ=1000), the id can
> rollover after ~65 seconds of idle time, which should be fine.
> 
> We also change the hash used in __ip_select_ident() to not only hash
> on daddr, but also saddr and protocol, so that ICMP probes can not be
> used to infer information for other protocols.
> 
> For IPv6, adds saddr into the hash as well, but not nexthdr.
> 
> If I ping the patched target, we can see ID are now hard to predict.
 ...
> [1] TCP sessions uses a per flow ID generator not changed by this patch.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Jeffrey Knockel <jeffk@cs.unm.edu>
> Reported-by: Jedidiah R. Crandall <crandall@cs.unm.edu>

Applied and queued up for -stable, thanks everyone.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive
 for TCP
Date: Mon, 23 Apr 2012 16:01:49 -0400 (EDT)
Message-ID: <20120423.160149.1515408777176168288.davem@davemloft.net>
References: <1335173934.3293.84.camel@edumazet-glaptop>
	<4F958DFD.7010207@hp.com>
	<1335201795.5205.35.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org, therbert@google.com,
	ncardwell@google.com, maze@google.com, ycheng@google.com,
	ilpo.jarvinen@helsinki.fi
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59948 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754071Ab2DWUCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 16:02:16 -0400
In-Reply-To: <1335201795.5205.35.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 23 Apr 2012 19:23:15 +0200

> On Mon, 2012-04-23 at 10:14 -0700, Rick Jones wrote:
> 
>> 
>> This will increase what can be queued for arriving segments in general 
>> and not for ACKs specifically yes?  (A possible issue that would have 
>> come-up with my previous wondering about just increasing SO_RCVBUF as 
>> SO_SNDBUF was increasing).  Perhaps only add sk->sk_sndbuf to the limit 
>> if the arriving segment contains no data?
> 
> Thats the backlog limit that we tweak here.
> 
> Its not a big deal if we allow a bit more packets to come and later drop
> them if we hit the real rcvbuf limit. (ACKS wont consume space, since
> they are freed as soon as processed)

Hmmm... why don't we just acknowledge reality and special case ACKs?

If a TCP packet is dataless we should just let it go through no matter
what and with no limits.  It is by definition transient and will not
get queued up into the socket past this backlog stage.

This proposed patch allows non-dataless packets to eat more space in
the backlog, thus the concern and slight pushback.  And from another
perspective, having the stack process data packets which will just
get dropped when we try to attach it to the receive queue is just
wasted work.

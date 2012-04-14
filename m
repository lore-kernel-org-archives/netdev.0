From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: RFC6298 supersedes RFC2988bis
Date: Sat, 14 Apr 2012 15:47:24 -0400 (EDT)
Message-ID: <20120414.154724.636922650012404380.davem@davemloft.net>
References: <1334296120.5300.8404.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hkchu@google.com, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59822 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752253Ab2DNTr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2012 15:47:28 -0400
In-Reply-To: <1334296120.5300.8404.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 13 Apr 2012 07:48:40 +0200

> Updates some comments to track RFC6298
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: H.K. Jerry Chu <hkchu@google.com>
> Cc: Tom Herbert <therbert@google.com>

Applied.

> BTW, one side effect of the TCP_TIMEOUT_INIT change (3 -> 1) is
> inet_csk_reqsk_queue_prune() latency is 200% worse:
> 
> It fires every 200ms and scans 40% of hash table each time, listener
> socket held.

That's rather unfortunate, but I can't see an easy way around it.  We
have to process the whole table within the timeout quantum.

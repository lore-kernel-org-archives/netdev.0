From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: sk_add_backlog() take rmem_alloc
 into account
Date: Tue, 27 Apr 2010 14:43:07 -0700 (PDT)
Message-ID: <20100427.144307.22037530.davem@davemloft.net>
References: <20100427.102038.57469310.davem@davemloft.net>
	<1272389872.2295.405.camel@edumazet-laptop>
	<1272399662.2343.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bmb@athenacr.com, therbert@google.com, netdev@vger.kernel.org,
	rick.jones2@hp.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47652
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757120Ab0D0VnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 17:43:01 -0400
In-Reply-To: <1272399662.2343.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 27 Apr 2010 22:21:02 +0200

> [PATCH net-next-2.6] net: sk_add_backlog() take rmem_alloc into account
> 
> Current socket backlog limit is not enough to really stop DDOS attacks,
> because user thread spend many time to process a full backlog each
> round, and user might crazy spin on socket lock.
> 
> We should add backlog size and receive_queue size (aka rmem_alloc) to
> pace writers, and let user run without being slow down too much.
> 
> Introduce a sk_rcvqueues_full() helper, to avoid taking socket lock in
> stress situations.
> 
> Under huge stress from a multiqueue/RPS enabled NIC, a single flow udp
> receiver can now process ~200.000 pps (instead of ~100 pps before the
> patch) on a 8 core machine.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

This looks great, applied, thanks Eric!

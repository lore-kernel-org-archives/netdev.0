From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp/dccp: fix inet_reuseport_add_sock()
Date: Thu, 07 Apr 2016 12:02:56 -0400 (EDT)
Message-ID: <20160407.120256.283752166035245785.davem@davemloft.net>
References: <5705A392.2000207@cumulusnetworks.com>
	<1460005654.6473.377.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org,
	edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835AbcDGQC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 12:02:58 -0400
In-Reply-To: <1460005654.6473.377.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Apr 2016 22:07:34 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> David Ahern reported panics in __inet_hash() caused by my recent commit.
> 
> The reason is inet_reuseport_add_sock() was still using
> sk_nulls_for_each_rcu() instead of sk_for_each_rcu().
> SO_REUSEPORT enabled listeners were causing an instant crash.
> 
> While chasing this bug, I found that I forgot to clear SOCK_RCU_FREE
> flag, as it is inherited from the parent at clone time.
> 
> Fixes: 3b24d854cb35 ("tcp/dccp: do not touch listener sk_refcnt under synflood")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks Eric.

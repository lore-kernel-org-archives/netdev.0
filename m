From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp/dccp: add SLAB_DESTROY_BY_RCU flag for
 request sockets
Date: Sat, 03 Oct 2015 13:25:44 -0700 (PDT)
Message-ID: <20151003.132544.1489547849171491402.davem@davemloft.net>
References: <1443878848.32531.70.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58080 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932AbbJCUK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2015 16:10:28 -0400
In-Reply-To: <1443878848.32531.70.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 03 Oct 2015 06:27:28 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Before letting request sockets being put in TCP/DCCP regular
> ehash table, we need to add either :
> 
> - SLAB_DESTROY_BY_RCU flag to their kmem_cache
> - add RCU grace period before freeing them.
> 
> Since we carefully respected the SLAB_DESTROY_BY_RCU protocol
> like ESTABLISH and TIMEWAIT sockets, use it here.
> 
> req_prot_init() being only used by TCP and DCCP, I did not add
> a new slab_flags into their rsk_prot, but reuse prot->slab_flags
> 
> Since all reqsk_alloc() users are correctly dealing with a failure,
> add the __GFP_NOWARN flag to avoid traces under pressure.
> 
> Fixes: 079096f103fa ("tcp/dccp: install syn_recv requests into ehash table")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.

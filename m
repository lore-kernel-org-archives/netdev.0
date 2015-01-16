From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] net: rps: fix cpu unplug
Date: Fri, 16 Jan 2015 01:05:32 -0500 (EST)
Message-ID: <20150116.010532.827422113288970815.davem@davemloft.net>
References: <1421350095.11734.88.camel@edumazet-glaptop2.roam.corp.google.com>
	<1421358383.11734.97.camel@edumazet-glaptop2.roam.corp.google.com>
	<1421370262.11734.111.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: subashab@codeaurora.org, psodagud@codeaurora.org,
	netdev@vger.kernel.org, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57490 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbbAPGFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 01:05:34 -0500
In-Reply-To: <1421370262.11734.111.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 15 Jan 2015 17:04:22 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> softnet_data.input_pkt_queue is protected by a spinlock that
> we must hold when transferring packets from victim queue to an active
> one. This is because other cpus could still be trying to enqueue packets
> into victim queue.
> 
> A second problem is that when we transfert the NAPI poll_list from
> victim to current cpu, we absolutely need to special case the percpu
> backlog, because we do not want to add complex locking to protect
> process_queue : Only owner cpu is allowed to manipulate it, unless cpu
> is offline.
> 
> Based on initial patch from Prasad Sodagudi & Subash Abhinov
> Kasiviswanathan.
> 
> This version is better because we do not slow down packet processing,
> only make migration safer.
> 
> Reported-by: Prasad Sodagudi <psodagud@codeaurora.org>
> Reported-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.

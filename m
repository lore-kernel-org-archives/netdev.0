From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp/dccp: fix hashdance race for passive
 sessions
Date: Fri, 23 Oct 2015 05:43:06 -0700 (PDT)
Message-ID: <20151023.054306.857450545092417631.davem@davemloft.net>
References: <1445527246.22974.125.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34557 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827AbbJWM0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 08:26:40 -0400
In-Reply-To: <1445527246.22974.125.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 22 Oct 2015 08:20:46 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Multiple cpus can process duplicates of incoming ACK messages
> matching a SYN_RECV request socket. This is a rare event under
> normal operations, but definitely can happen.
> 
> Only one must win the race, otherwise corruption would occur.
> 
> To fix this without adding new atomic ops, we use logic in
> inet_ehash_nolisten() to detect the request was present in the same
> ehash bucket where we try to insert the new child.
> 
> If request socket was not found, we have to undo the child creation. 
> 
> This actually removes a spin_lock()/spin_unlock() pair in
> reqsk_queue_unlink() for the fast path.
> 
> Fixes: e994b2f0fb92 ("tcp: do not lock listener to process SYN packets")
> Fixes: 079096f103fa ("tcp/dccp: install syn_recv requests into ehash table")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: tainted warnings with tcp splicing in 3.7.1
Date: Thu, 10 Jan 2013 14:39:55 -0800 (PST)
Message-ID: <20130110.143955.1612875084927284724.davem@davemloft.net>
References: <1357750898.27446.33.camel@edumazet-glaptop>
	<1357751372.27446.40.camel@edumazet-glaptop>
	<1357801149.27446.1142.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: c.becker@traviangames.com, netdev@vger.kernel.org, w@1wt.eu
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34610 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753231Ab3AJWjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 17:39:55 -0500
In-Reply-To: <1357801149.27446.1142.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 09 Jan 2013 22:59:09 -0800

> [PATCH] tcp: fix splice() and tcp collapsing interaction
> 
> Under unusual circumstances, TCP collapse can split a big GRO TCP packet
> while its being used in a splice(socket->pipe) operation.
> 
> skb_splice_bits() releases the socket lock before calling
> splice_to_pipe().
> 
> [ 1081.353685] WARNING: at net/ipv4/tcp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> [ 1081.371956] Hardware name: System x3690 X5 -[7148Z68]-
> [ 1081.391820] cleanup rbuf bug: copied AD3BCF1 seq AD370AF rcvnxt AD3CF13
> 
> To fix this problem, we must eat skbs in tcp_recv_skb().
> 
> Remove the inline keyword from tcp_recv_skb() definition since
> it has three call sites.
> 
> Reported-by: Christian Becker <c.becker@traviangames.com>
> Cc: Willy Tarreau <w@1wt.eu>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inet: fix possible request socket leak
Date: Mon, 10 Aug 2015 21:18:30 -0700 (PDT)
Message-ID: <20150810.211830.520449658624351173.davem@davemloft.net>
References: <1439244454.1084.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46136 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707AbbHKESb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 00:18:31 -0400
In-Reply-To: <1439244454.1084.22.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 10 Aug 2015 15:07:34 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In commit b357a364c57c9 ("inet: fix possible panic in
> reqsk_queue_unlink()"), I missed fact that tcp_check_req()
> can return the listener socket in one case, and that we must
> release the request socket refcount or we leak it.
> 
> Tested:
> 
>  Following packetdrill test template shows the issue
> 
> 0     socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
> +0    setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
> +0    bind(3, ..., ...) = 0
> +0    listen(3, 1) = 0
> 
> +0    < S 0:0(0) win 2920 <mss 1460,sackOK,nop,nop>
> +0    > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK>
> +.002 < . 1:1(0) ack 21 win 2920
> +0    > R 21:21(0)
> 
> Fixes: b357a364c57c9 ("inet: fix possible panic in reqsk_queue_unlink()")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.

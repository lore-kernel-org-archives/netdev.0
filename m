From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp/dccp: fix lockdep splat in inet_csk_route_req()
Date: Mon, 23 Oct 2017 05:46:27 +0100 (WEST)
Message-ID: <20171023.054627.999192892187895351.davem@davemloft.net>
References: <1508700837.30291.63.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41500 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750995AbdJWEq2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 00:46:28 -0400
In-Reply-To: <1508700837.30291.63.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 22 Oct 2017 12:33:57 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> This patch fixes the following lockdep splat in inet_csk_route_req()
> 
>   lockdep_rcu_suspicious
>   inet_csk_route_req
>   tcp_v4_send_synack
>   tcp_rtx_synack
>   inet_rtx_syn_ack
>   tcp_fastopen_synack_time
>   tcp_retransmit_timer
>   tcp_write_timer_handler
>   tcp_write_timer
>   call_timer_fn
> 
> Thread running inet_csk_route_req() owns a reference on the request
> socket, so we have the guarantee ireq->ireq_opt wont be changed or
> freed.
> 
> lockdep can enforce this invariant for us.
> 
> Fixes: c92e8c02fe66 ("tcp/dccp: fix ireq->opt races")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.

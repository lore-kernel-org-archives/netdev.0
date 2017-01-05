From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] tcp: provide timestamps for partial writes
Date: Thu, 05 Jan 2017 14:56:40 -0500 (EST)
Message-ID: <20170105.145640.1963005404677444663.davem@davemloft.net>
References: <20170104161934.26849-1-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, soheil@google.com, willemb@google.com,
        edumazet@google.com, ncardwell@google.com, kafai@fb.com
To: soheil.kdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48466 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935446AbdAET4m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 14:56:42 -0500
In-Reply-To: <20170104161934.26849-1-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Date: Wed,  4 Jan 2017 11:19:34 -0500

> From: Soheil Hassas Yeganeh <soheil@google.com>
> 
> For TCP sockets, TX timestamps are only captured when the user data
> is successfully and fully written to the socket. In many cases,
> however, TCP writes can be partial for which no timestamp is
> collected.
> 
> Collect timestamps whenever any user data is (fully or partially)
> copied into the socket. Pass tcp_write_queue_tail to tcp_tx_timestamp
> instead of the local skb pointer since it can be set to NULL on
> the error path.
> 
> Note that tcp_write_queue_tail can be NULL, even if bytes have been
> copied to the socket. This is because acknowledgements are being
> processed in tcp_sendmsg(), and by the time tcp_tx_timestamp is
> called tcp_write_queue_tail can be NULL. For such cases, this patch
> does not collect any timestamps (i.e., it is best-effort).
> 
> This patch is written with suggestions from Willem de Bruijn and
> Eric Dumazet.
> 
> Change-log V1 -> V2:
> 	- Use sockc.tsflags instead of sk->sk_tsflags.
> 	- Use the same code path for normal writes and errors.
> 
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>

Applied, thanks.

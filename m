From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] tcp: uniform the set up of sockets after
 successful connection
Date: Tue, 03 Oct 2017 21:28:26 -0700 (PDT)
Message-ID: <20171003.212826.427984613713921100.davem@davemloft.net>
References: <20171002170135.106183-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, ncardwell@google.com,
        edumazet@google.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32852 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751047AbdJDE21 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 00:28:27 -0400
In-Reply-To: <20171002170135.106183-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Mon,  2 Oct 2017 10:01:35 -0700

> @@ -456,6 +456,19 @@ void tcp_init_sock(struct sock *sk)
>  }
>  EXPORT_SYMBOL(tcp_init_sock);
>  
> +void tcp_init_transfer(struct sock *sk, int bpf_op)
> +{
> +	struct inet_connection_sock *icsk = inet_csk(sk);
> +
> +	tcp_mtup_init(sk);
> +	icsk->icsk_af_ops->rebuild_header(sk);
> +	tcp_init_metrics(sk);
> +	tcp_call_bpf(sk, bpf_op);
> +	tcp_init_congestion_control(sk);
> +	tcp_init_buffer_space(sk);
> +}
> +EXPORT_SYMBOL(tcp_init_transfer);

This symbol export is unnecessary, and if it were it should
be EXPORT_SYMBOL_GPL().

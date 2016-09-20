From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: xt_socket: fix transparent match for IPv6
 request sockets
Date: Tue, 20 Sep 2016 08:05:35 -0700
Message-ID: <1474383935.23058.20.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160920132637.221892-1-hidden@balabit.com>
         <1474383672.23058.19.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        netfilter-devel@vger.kernel.org,
        Alex Badics <alex.badics@balabit.com>,
        netdev <netdev@vger.kernel.org>
To: KOVACS Krisztian <hidden@balabit.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36637 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752654AbcITPFh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 11:05:37 -0400
In-Reply-To: <1474383672.23058.19.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-20 at 08:01 -0700, Eric Dumazet wrote:

> 
> Something like :
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 3ebf45b38bc3..0fccfd6cc258 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -6264,6 +6264,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
>  	/* Note: tcp_v6_init_req() might override ir_iif for link locals */
>  	inet_rsk(req)->ir_iif = inet_request_bound_dev_if(sk, skb);
>  
> +	ireq->no_srccheck = inet_sk(sk)->transparent;

Since there is no @ireq there, simply use :

	inet_rsk(req)->no_srccheck = inet_sk(sk)->transparent;


>  	af_ops->init_req(req, sk, skb);
>  

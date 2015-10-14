From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] tcp/dccp: fix race at listener dismantle
 phase
Date: Wed, 14 Oct 2015 11:13:25 -0700
Message-ID: <1444846405.4166.39.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1444845519-20064-1-git-send-email-edumazet@google.com>
	 <1444845519-20064-4-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33148 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752222AbbJNSN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 14:13:27 -0400
Received: by pabrc13 with SMTP id rc13so60957661pab.0
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 11:13:27 -0700 (PDT)
In-Reply-To: <1444845519-20064-4-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-10-14 at 10:58 -0700, Eric Dumazet wrote:


...


> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
> index a5a1b54915e5..38b7ef8b0b78 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -740,7 +740,7 @@ int inet_csk_listen_start(struct sock *sk, const int nr_table_entries)
>  
>  	reqsk_queue_alloc(&icsk->icsk_accept_queue);
>  
> -	sk->sk_max_ack_backlog = 0;
> +	sk->sk_max_ack_backlog = nr_table_entries;
>  	sk->sk_ack_backlog = 0;
>  	inet_csk_delack_init(sk);
>  
> @@ -764,6 +764,53 @@ int inet_csk_listen_start(struct sock *sk, const int nr_table_entries)


Arg, this part was not meant to be there, sorry. Will send a v2

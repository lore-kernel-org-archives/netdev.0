From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net 3/3] sctp: also copy sk_tsflags when copying the
 socket
Date: Fri, 4 Dec 2015 15:33:26 -0500
Message-ID: <5661F896.2040706@gmail.com>
References: <20151203184316.GF4164@mrl.redhat.com>
 <cover.1449249050.git.marcelo.leitner@gmail.com>
 <ff20b0d68e8652db4406e4b19c93404f9c32637a.1449249050.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	syzkaller <syzkaller@googlegroups.com>,
	linux-sctp@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	=?UTF-8?Q?Maciej_=c5=bbenczykowski?= <maze@google.com>,
	Dmitry Vyukov <dvyukov@google.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f65.google.com ([209.85.192.65]:33641 "EHLO
	mail-qg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754819AbbLDUd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 15:33:29 -0500
In-Reply-To: <ff20b0d68e8652db4406e4b19c93404f9c32637a.1449249050.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/2015 12:14 PM, Marcelo Ricardo Leitner wrote:
> As we are keeping timestamps on when copying the socket, we also have to
> copy sk_tsflags.
> 
> This is needed since b9f40e21ef42 ("net-timestamp: move timestamp flags
> out of sk_flags").
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>  net/sctp/socket.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 4c9282bdd06790a0cca7f7c33986e7eb6c541398..1a32ecdb8bae98de2e76591f0f5ffee1441ff04d 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -7167,6 +7167,7 @@ void sctp_copy_sock(struct sock *newsk, struct sock *sk,
>  	newsk->sk_type = sk->sk_type;
>  	newsk->sk_bound_dev_if = sk->sk_bound_dev_if;
>  	newsk->sk_flags = sk->sk_flags;
> +	newsk->sk_tsflags = sk->sk_tsflags;
>  	newsk->sk_no_check_tx = sk->sk_no_check_tx;
>  	newsk->sk_no_check_rx = sk->sk_no_check_rx;
>  	newsk->sk_reuse = sk->sk_reuse;
> 

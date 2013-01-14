From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH] tcp: fix a panic on UP machines in reqsk_fastopen_remove
Date: Mon, 14 Jan 2013 00:26:26 -0800
Message-ID: <CAPshTCiNcSPbC7uCzo5MV2tGuZyoCwyE_XKcGb9smknZ8Rqb2w@mail.gmail.com>
References: <1358137311.8744.1590.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ketan Kulkarni <ketkulka@gmail.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:42344 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755322Ab3ANIdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 03:33:25 -0500
Received: by mail-lb0-f169.google.com with SMTP id gk1so2748063lbb.28
        for <netdev@vger.kernel.org>; Mon, 14 Jan 2013 00:33:24 -0800 (PST)
In-Reply-To: <1358137311.8744.1590.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 13, 2013 at 8:21 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> spin_is_locked() on a non !SMP build is kind of useless.
>
> BUG_ON(!spin_is_locked(xx)) is guaranteed to crash.
>
> Just remove this check in reqsk_fastopen_remove() as
> the callers do hold the socket lock.
>
> Reported-by: Ketan Kulkarni <ketkulka@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jerry Chu <hkchu@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Dave Taht <dave.taht@gmail.com>
> ---
>  net/core/request_sock.c |    2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/net/core/request_sock.c b/net/core/request_sock.c
> index c31d9e8..4425148 100644
> --- a/net/core/request_sock.c
> +++ b/net/core/request_sock.c
> @@ -186,8 +186,6 @@ void reqsk_fastopen_remove(struct sock *sk, struct request_sock *req,
>         struct fastopen_queue *fastopenq =
>             inet_csk(lsk)->icsk_accept_queue.fastopenq;
>
> -       BUG_ON(!spin_is_locked(&sk->sk_lock.slock) && !sock_owned_by_user(sk));
> -
>         tcp_sk(sk)->fastopen_rsk = NULL;
>         spin_lock_bh(&fastopenq->lock);
>         fastopenq->qlen--;
>
>

Thanks, Eric. (I thought the assertion would be transparent to UP...)

Acked-by: H.K. Jerry Chu <hkchu@google.com>

From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net-next 12/15] tcp_westwood: use tcp_jiffies32 instead of tcp_time_stamp
Date: Wed, 17 May 2017 09:47:15 -0400
Message-ID: <CACSApvYEQuwotereOWrsQ1T96Ld0JrJmNKNn=um_NYfSt5Vc6w@mail.gmail.com>
References: <20170516210014.31176-1-edumazet@google.com> <20170516210014.31176-13-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S . Miller" <davem@davemloft.net>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Wei Wang <weiwan@google.com>, netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:35876 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751781AbdEQNsC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 09:48:02 -0400
Received: by mail-it0-f43.google.com with SMTP id o5so81427522ith.1
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 06:47:57 -0700 (PDT)
In-Reply-To: <20170516210014.31176-13-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 5:00 PM, Eric Dumazet <edumazet@google.com> wrote:
> This CC does not need 1 ms tcp_time_stamp and can use
> the jiffy based 'timestamp'.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

> ---
>  net/ipv4/tcp_westwood.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp_westwood.c
> index 9775453b8d174c848dc09df83d1fa185422cd8cc..bec9cafbe3f92938e5d79d743d629b2f33464418 100644
> --- a/net/ipv4/tcp_westwood.c
> +++ b/net/ipv4/tcp_westwood.c
> @@ -68,7 +68,7 @@ static void tcp_westwood_init(struct sock *sk)
>         w->cumul_ack = 0;
>         w->reset_rtt_min = 1;
>         w->rtt_min = w->rtt = TCP_WESTWOOD_INIT_RTT;
> -       w->rtt_win_sx = tcp_time_stamp;
> +       w->rtt_win_sx = tcp_jiffies32;
>         w->snd_una = tcp_sk(sk)->snd_una;
>         w->first_ack = 1;
>  }
> @@ -116,7 +116,7 @@ static void tcp_westwood_pkts_acked(struct sock *sk,
>  static void westwood_update_window(struct sock *sk)
>  {
>         struct westwood *w = inet_csk_ca(sk);
> -       s32 delta = tcp_time_stamp - w->rtt_win_sx;
> +       s32 delta = tcp_jiffies32 - w->rtt_win_sx;
>
>         /* Initialize w->snd_una with the first acked sequence number in order
>          * to fix mismatch between tp->snd_una and w->snd_una for the first
> @@ -140,7 +140,7 @@ static void westwood_update_window(struct sock *sk)
>                 westwood_filter(w, delta);
>
>                 w->bk = 0;
> -               w->rtt_win_sx = tcp_time_stamp;
> +               w->rtt_win_sx = tcp_jiffies32;
>         }
>  }
>
> --
> 2.13.0.303.g4ebf302169-goog
>

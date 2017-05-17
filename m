From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net-next 10/15] tcp: uses jiffies_32 to feed tp->chrono_start
Date: Wed, 17 May 2017 09:46:52 -0400
Message-ID: <CACSApvbbjOxfTV2qv=ousNTW9OoEkG8NTVQb_Du0q1teZ9W1Kg@mail.gmail.com>
References: <20170516210014.31176-1-edumazet@google.com> <20170516210014.31176-11-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S . Miller" <davem@davemloft.net>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Wei Wang <weiwan@google.com>, netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:33912 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752165AbdEQNrd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 09:47:33 -0400
Received: by mail-it0-f53.google.com with SMTP id a10so16722873itg.1
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 06:47:33 -0700 (PDT)
In-Reply-To: <20170516210014.31176-11-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 5:00 PM, Eric Dumazet <edumazet@google.com> wrote:
> tcp_time_stamp will no longer be tied to jiffies.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

> ---
>  net/ipv4/tcp.c        | 2 +-
>  net/ipv4/tcp_output.c | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index d0bb61ee28bbceff8f2e27416ce87fec94935973..b85bfe7cb11dca68952cc4be19b169d893963fef 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2757,7 +2757,7 @@ static void tcp_get_info_chrono_stats(const struct tcp_sock *tp,
>         for (i = TCP_CHRONO_BUSY; i < __TCP_CHRONO_MAX; ++i) {
>                 stats[i] = tp->chrono_stat[i - 1];
>                 if (i == tp->chrono_type)
> -                       stats[i] += tcp_time_stamp - tp->chrono_start;
> +                       stats[i] += tcp_jiffies32 - tp->chrono_start;
>                 stats[i] *= USEC_PER_SEC / HZ;
>                 total += stats[i];
>         }
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index f0fd1b4fdb3291638fcdca613d826db2cd27f517..1011ea40c2ba4c12cce21149cab176e1fa4db583 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2202,7 +2202,7 @@ static bool tcp_small_queue_check(struct sock *sk, const struct sk_buff *skb,
>
>  static void tcp_chrono_set(struct tcp_sock *tp, const enum tcp_chrono new)
>  {
> -       const u32 now = tcp_time_stamp;
> +       const u32 now = tcp_jiffies32;
>
>         if (tp->chrono_type > TCP_CHRONO_UNSPEC)
>                 tp->chrono_stat[tp->chrono_type - 1] += now - tp->chrono_start;
> --
> 2.13.0.303.g4ebf302169-goog
>

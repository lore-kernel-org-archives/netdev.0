From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net-next 06/15] tcp_bbr: use tcp_jiffies32 instead of tcp_time_stamp
Date: Wed, 17 May 2017 09:45:43 -0400
Message-ID: <CACSApvYSCeKD4ctwHfpkBt9jtJFCRdmq7Pg5_-My0kA_SfQKUA@mail.gmail.com>
References: <20170516210014.31176-1-edumazet@google.com> <20170516210014.31176-7-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S . Miller" <davem@davemloft.net>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Wei Wang <weiwan@google.com>, netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:36222 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753656AbdEQNqY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 09:46:24 -0400
Received: by mail-it0-f47.google.com with SMTP id o5so81397117ith.1
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 06:46:24 -0700 (PDT)
In-Reply-To: <20170516210014.31176-7-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 5:00 PM, Eric Dumazet <edumazet@google.com> wrote:
> Use tcp_jiffies32 instead of tcp_time_stamp, since
> tcp_time_stamp will soon be only used for TCP TS option.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

> ---
>  net/ipv4/tcp_bbr.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
>
> diff --git a/net/ipv4/tcp_bbr.c b/net/ipv4/tcp_bbr.c
> index 92b045c72163def1c1d6aa0f2002760186aa5dc3..40dc4fc5f6acba91634290e1cacde69a3584248f 100644
> --- a/net/ipv4/tcp_bbr.c
> +++ b/net/ipv4/tcp_bbr.c
> @@ -730,12 +730,12 @@ static void bbr_update_min_rtt(struct sock *sk, const struct rate_sample *rs)
>         bool filter_expired;
>
>         /* Track min RTT seen in the min_rtt_win_sec filter window: */
> -       filter_expired = after(tcp_time_stamp,
> +       filter_expired = after(tcp_jiffies32,
>                                bbr->min_rtt_stamp + bbr_min_rtt_win_sec * HZ);
>         if (rs->rtt_us >= 0 &&
>             (rs->rtt_us <= bbr->min_rtt_us || filter_expired)) {
>                 bbr->min_rtt_us = rs->rtt_us;
> -               bbr->min_rtt_stamp = tcp_time_stamp;
> +               bbr->min_rtt_stamp = tcp_jiffies32;
>         }
>
>         if (bbr_probe_rtt_mode_ms > 0 && filter_expired &&
> @@ -754,7 +754,7 @@ static void bbr_update_min_rtt(struct sock *sk, const struct rate_sample *rs)
>                 /* Maintain min packets in flight for max(200 ms, 1 round). */
>                 if (!bbr->probe_rtt_done_stamp &&
>                     tcp_packets_in_flight(tp) <= bbr_cwnd_min_target) {
> -                       bbr->probe_rtt_done_stamp = tcp_time_stamp +
> +                       bbr->probe_rtt_done_stamp = tcp_jiffies32 +
>                                 msecs_to_jiffies(bbr_probe_rtt_mode_ms);
>                         bbr->probe_rtt_round_done = 0;
>                         bbr->next_rtt_delivered = tp->delivered;
> @@ -762,8 +762,8 @@ static void bbr_update_min_rtt(struct sock *sk, const struct rate_sample *rs)
>                         if (bbr->round_start)
>                                 bbr->probe_rtt_round_done = 1;
>                         if (bbr->probe_rtt_round_done &&
> -                           after(tcp_time_stamp, bbr->probe_rtt_done_stamp)) {
> -                               bbr->min_rtt_stamp = tcp_time_stamp;
> +                           after(tcp_jiffies32, bbr->probe_rtt_done_stamp)) {
> +                               bbr->min_rtt_stamp = tcp_jiffies32;
>                                 bbr->restore_cwnd = 1;  /* snap to prior_cwnd */
>                                 bbr_reset_mode(sk);
>                         }
> @@ -810,7 +810,7 @@ static void bbr_init(struct sock *sk)
>         bbr->probe_rtt_done_stamp = 0;
>         bbr->probe_rtt_round_done = 0;
>         bbr->min_rtt_us = tcp_min_rtt(tp);
> -       bbr->min_rtt_stamp = tcp_time_stamp;
> +       bbr->min_rtt_stamp = tcp_jiffies32;
>
>         minmax_reset(&bbr->bw, bbr->rtt_cnt, 0);  /* init max bw to 0 */
>
> --
> 2.13.0.303.g4ebf302169-goog
>

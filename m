From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2] tcp: reduce the bloat caused by tcp_is_cwnd_limited()
Date: Sun, 23 Feb 2014 10:16:29 -0500
Message-ID: <CADVnQyk_t+5fh1Mt-CGQ-NkDoCrv_Pkh7KYqivXDy1x3Kz18dA@mail.gmail.com>
References: <1393105959.2316.30.camel@edumazet-glaptop2.roam.corp.google.com>
	<1393136757.2316.39.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Van Jacobson <vanj@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:54159 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbaBWPQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Feb 2014 10:16:32 -0500
Received: by mail-ee0-f42.google.com with SMTP id e53so1034053eek.15
        for <netdev@vger.kernel.org>; Sun, 23 Feb 2014 07:16:30 -0800 (PST)
In-Reply-To: <1393136757.2316.39.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 23, 2014 at 1:25 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
...
> v2: addressed Neal point about keeping first condition.
>
>  net/ipv4/tcp_cong.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
> index ad37bf18ae4b..2388275adb9b 100644
> --- a/net/ipv4/tcp_cong.c
> +++ b/net/ipv4/tcp_cong.c
> @@ -290,8 +290,7 @@ bool tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight)
>         left = tp->snd_cwnd - in_flight;
>         if (sk_can_gso(sk) &&
>             left * sysctl_tcp_tso_win_divisor < tp->snd_cwnd &&
> -           left * tp->mss_cache < sk->sk_gso_max_size &&
> -           left < sk->sk_gso_max_segs)
> +           left < tp->xmit_size_goal_segs)
>                 return true;
>         return left <= tcp_max_tso_deferred_mss(tp);
>  }

Looks great to me. Thanks!

Acked-by: Neal Cardwell <ncardwell@google.com>

neal

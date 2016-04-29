From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH v2 net-next 3/7] dccp: do not assume DCCP code is non preemptible
Date: Fri, 29 Apr 2016 09:21:17 -0400
Message-ID: <CACSApvZKpfC1DTvMUjfFVk9fi9Swxq0Dn7-jyYsgwcz76OMuWg@mail.gmail.com>
References: <1461899449-8096-1-git-send-email-edumazet@google.com> <1461899449-8096-4-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:35655 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752625AbcD2NV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 09:21:57 -0400
Received: by mail-oi0-f41.google.com with SMTP id x19so117798825oix.2
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 06:21:56 -0700 (PDT)
In-Reply-To: <1461899449-8096-4-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 28, 2016 at 11:10 PM, Eric Dumazet <edumazet@google.com> wrote:
> DCCP uses the generic backlog code, and this will soon
> be changed to not disable BH when protocol is called back.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
> ---
>  net/dccp/input.c   | 2 +-
>  net/dccp/ipv4.c    | 4 ++--
>  net/dccp/ipv6.c    | 4 ++--
>  net/dccp/options.c | 2 +-
>  4 files changed, 6 insertions(+), 6 deletions(-)
>
> diff --git a/net/dccp/input.c b/net/dccp/input.c
> index 2437ecc13b82..ba347184bda9 100644
> --- a/net/dccp/input.c
> +++ b/net/dccp/input.c
> @@ -359,7 +359,7 @@ send_sync:
>                 goto discard;
>         }
>
> -       __DCCP_INC_STATS(DCCP_MIB_INERRS);
> +       DCCP_INC_STATS(DCCP_MIB_INERRS);
>  discard:
>         __kfree_skb(skb);
>         return 0;
> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> index a8164272e0f4..5c7e413a3ae4 100644
> --- a/net/dccp/ipv4.c
> +++ b/net/dccp/ipv4.c
> @@ -533,8 +533,8 @@ static void dccp_v4_ctl_send_reset(const struct sock *sk, struct sk_buff *rxskb)
>         bh_unlock_sock(ctl_sk);
>
>         if (net_xmit_eval(err) == 0) {
> -               __DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
> -               __DCCP_INC_STATS(DCCP_MIB_OUTRSTS);
> +               DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
> +               DCCP_INC_STATS(DCCP_MIB_OUTRSTS);
>         }
>  out:
>          dst_release(dst);
> diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
> index 0f4eb4ea57a5..d176f4e66369 100644
> --- a/net/dccp/ipv6.c
> +++ b/net/dccp/ipv6.c
> @@ -277,8 +277,8 @@ static void dccp_v6_ctl_send_reset(const struct sock *sk, struct sk_buff *rxskb)
>         if (!IS_ERR(dst)) {
>                 skb_dst_set(skb, dst);
>                 ip6_xmit(ctl_sk, skb, &fl6, NULL, 0);
> -               __DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
> -               __DCCP_INC_STATS(DCCP_MIB_OUTRSTS);
> +               DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
> +               DCCP_INC_STATS(DCCP_MIB_OUTRSTS);
>                 return;
>         }
>
> diff --git a/net/dccp/options.c b/net/dccp/options.c
> index b82b7ee9a1d2..74d29c56c367 100644
> --- a/net/dccp/options.c
> +++ b/net/dccp/options.c
> @@ -253,7 +253,7 @@ out_nonsensical_length:
>         return 0;
>
>  out_invalid_option:
> -       __DCCP_INC_STATS(DCCP_MIB_INVALIDOPT);
> +       DCCP_INC_STATS(DCCP_MIB_INVALIDOPT);
>         rc = DCCP_RESET_CODE_OPTION_ERROR;
>  out_featneg_failed:
>         DCCP_WARN("DCCP(%p): Option %d (len=%d) error=%u\n", sk, opt, len, rc);
> --
> 2.8.0.rc3.226.g39d4020
>

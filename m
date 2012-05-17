From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] tcp: bool conversions
Date: Thu, 17 May 2012 13:46:36 +0100
Message-ID: <1337258796.2496.6.camel@bwh-desktop.uk.solarflarecom.com>
References: <1337246134.4740.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51851 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754564Ab2EQMqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 08:46:43 -0400
In-Reply-To: <1337246134.4740.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-17 at 11:15 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> bool conversions where possible.

There's a bit more than bool conversions here:

[...]
> --- a/net/ipv4/tcp_hybla.c
> +++ b/net/ipv4/tcp_hybla.c
[...]
> @@ -24,8 +24,7 @@ struct hybla {
>  	u32   minrtt;	      /* Minimum smoothed round trip time value seen */
>  };
>  
> -/* Hybla reference round trip time (default= 1/40 sec = 25 ms),
> -   expressed in jiffies */
> +/* Hybla reference round trip time (default= 1/40 sec = 25 ms), in ms */
>  static int rtt0 = 25;
>  module_param(rtt0, int, 0644);
>  MODULE_PARM_DESC(rtt0, "reference rout trip time (ms)");
> @@ -39,7 +38,7 @@ static inline void hybla_recalc_param (struct sock *sk)
>  	ca->rho_3ls = max_t(u32, tcp_sk(sk)->srtt / msecs_to_jiffies(rtt0), 8);
>  	ca->rho = ca->rho_3ls >> 3;
>  	ca->rho2_7ls = (ca->rho_3ls * ca->rho_3ls) << 1;
> -	ca->rho2 = ca->rho2_7ls >>7;
> +	ca->rho2 = ca->rho2_7ls >> 7;
>  }
>  
>  static void hybla_init(struct sock *sk)
[...] 
> @@ -67,6 +66,7 @@ static void hybla_init(struct sock *sk)
>  static void hybla_state(struct sock *sk, u8 ca_state)
>  {
>  	struct hybla *ca = inet_csk_ca(sk);
> +
>  	ca->hybla_en = (ca_state == TCP_CA_Open);
>  }
>  
[...]
> --- a/net/ipv4/tcp_minisocks.c
> +++ b/net/ipv4/tcp_minisocks.c
[...]
> -static __inline__ int tcp_in_window(u32 seq, u32 end_seq, u32 s_win, u32 e_win)
> +static bool tcp_in_window(u32 seq, u32 end_seq, u32 s_win, u32 e_win)
>  { 
[...]
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
[...]
>  /* Does at least the first segment of SKB fit into the send window? */
> -static inline int tcp_snd_wnd_test(const struct tcp_sock *tp, const struct sk_buff *skb,
> -				   unsigned int cur_mss)
> +static bool tcp_snd_wnd_test(const struct tcp_sock *tp,
> +			     const struct sk_buff *skb,
> +			     unsigned int cur_mss)
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/5] tcp: stretch ACK fixes prep
Date: Wed, 28 Jan 2015 15:00:42 -0800 (PST)
Message-ID: <20150128.150042.1853211263331246216.davem@davemloft.net>
References: <1422390883-15603-1-git-send-email-ncardwell@google.com>
	<1422390883-15603-2-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, edumazet@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34969 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755347AbbA2B3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 20:29:07 -0500
In-Reply-To: <1422390883-15603-2-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Tue, 27 Jan 2015 15:34:39 -0500

> -void tcp_slow_start(struct tcp_sock *tp, u32 acked);
 ...
> +int tcp_slow_start(struct tcp_sock *tp, u32 acked);
 ...
 ...
> @@ -360,25 +360,28 @@ int tcp_set_congestion_control(struct sock *sk, const char *name)
>   * ABC caps N to 2. Slow start exits when cwnd grows over ssthresh and
>   * returns the leftover acks to adjust cwnd in congestion avoidance mode.
>   */
> -void tcp_slow_start(struct tcp_sock *tp, u32 acked)
> +int tcp_slow_start(struct tcp_sock *tp, u32 acked)
>  {
>  	u32 cwnd = tp->snd_cwnd + acked;
>  
>  	if (cwnd > tp->snd_ssthresh)
>  		cwnd = tp->snd_ssthresh + 1;
> +	acked -= cwnd - tp->snd_cwnd;
>  	tp->snd_cwnd = min(cwnd, tp->snd_cwnd_clamp);
> +
> +	return acked;
>  }

'acked' is a u32, please have this function return a u32 as well.

In fact in all the call sites the return value gets assigned into a
local u32 variable as well, so I have no idea why you're using 'int'
here.

Thanks.

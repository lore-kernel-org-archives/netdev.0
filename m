From: Komuro <komurojun-mbn@nifty.com>
Subject: Re: [NOT VERY SAFE]     [TCP]: Set initial_ssthresh default to zero
 in Cubic and BIC.
Date: Mon, 15 Oct 2007 21:59:49 +0900
Message-ID: <20071015215949.50399c00.komurojun-mbn@nifty.com>
References: <20071006132601.f944f461.komurojun@nifty.com>
	<20071014073658.d4352b8c.komurojun@nifty.com>
	<20071014100245.914b784a.komurojun@nifty.com>
	<20071014132851.8d6a9de3.komurojun@nifty.com>
	<20071014135356.19754635.komurojun-mbn@nifty.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: shemminger@linux.foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg502.nifty.com ([202.248.238.82]:57270 "EHLO
	userg502.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760115AbXJONBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 09:01:03 -0400
In-Reply-To: <20071014135356.19754635.komurojun-mbn@nifty.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear shemminger

>In which case it is zero because that is the default value.

The default value of snd_ssthresh is 0x7fffffff, isn't it?

[linux/net/ipv4/tcp_ipv4.c]
static int tcp_v4_init_sock(struct sock *sk)
...
        tp->snd_ssthresh = 0x7fffffff;  /* Infinity */
...

Best Regards
Komuro


> 
> Actually, tcp_sk(sk)->snd_ssthresh is not initialized,
> if initial_ssthresh is 0.
> 
> The patch should be
> 
>  static void bictcp_init(struct sock *sk)
>  {
>  	bictcp_reset(inet_csk_ca(sk));
> -	if (initial_ssthresh)
> -		tcp_sk(sk)->snd_ssthresh = initial_ssthresh;
> +
> +	tcp_sk(sk)->snd_ssthresh = initial_ssthresh;
>  }
>

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] tcp: TCP experimental option for SMC
Date: Mon, 16 Oct 2017 09:13:27 -0700
Message-ID: <1508170407.31614.78.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171016154202.72635-1-ubraun@linux.vnet.ibm.com>
         <20171016154202.72635-2-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-s390@vger.kernel.org, jwi@linux.vnet.ibm.com,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com
To: Ursula Braun <ubraun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:46294 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754863AbdJPQNa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 12:13:30 -0400
In-Reply-To: <20171016154202.72635-2-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-10-16 at 17:42 +0200, Ursula Braun wrote:
...

> +static void smc_set_capability(struct inet_request_sock *ireq,
> +			       const struct tcp_options_received *rx_opt)
> +{
> +#if IS_ENABLED(CONFIG_SMC)
> +	if (!static_key_false(&tcp_have_smc))
> +		return;
> +
> +	if (rx_opt->smc_ok)
> +		ireq->smc_ok = 1;
> +	else
> +		ireq->smc_ok = 0;
> +#endif
> +}


I do not think this static_key_false(&tcp_have_smc)) makes sense here.

1) If you have a SYN packet while the key is not set
2) Then tcp_have_smc is changed
3) ACK packets comes,  and finds random value in ireq->smc_ok

So really here you have to set this field.

static void smc_set_capability(struct inet_request_sock *ireq,
                              const struct tcp_options_received *rx_opt)
{
#if IS_ENABLED(CONFIG_SMC)
       ireq->smc_ok = rx_opt->smc_ok;
#endif
}

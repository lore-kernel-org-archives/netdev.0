From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] tcp: switch rtt estimations to usec
 resolution
Date: Sun, 23 Feb 2014 09:36:30 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1402230908210.1460@ja.home.ssi.bg>
References: <1393137487.2316.48.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Larry Brakmo <brakmo@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:48979 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750946AbaBWHgy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Feb 2014 02:36:54 -0500
In-Reply-To: <1393137487.2316.48.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sat, 22 Feb 2014, Eric Dumazet wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Upcoming congestion controls for TCP require usec resolution for RTT
> estimations. Millisecond resolution is simply not enough these days.

...

> --- a/net/ipv4/tcp_metrics.c
> +++ b/net/ipv4/tcp_metrics.c

...

> @@ -408,10 +395,10 @@ void tcp_update_metrics(struct sock *sk)
>  	 */
>  	if (!tcp_metric_locked(tm, TCP_METRIC_RTT)) {
>  		if (m <= 0)
> -			rtt = tp->srtt;
> +			rtt = tp->srtt_us;
>  		else
>  			rtt -= (m >> 3);
> -		tcp_metric_set_msecs(tm, TCP_METRIC_RTT, rtt);
> +		tcp_metric_set(tm, TCP_METRIC_RTT, rtt);

	What is the way to handle this change of
resolution in TCP_METRICS_ATTR_VALS? The ip tool has
code in ip/tcp_metrics.c process_msg() that needs to
know what we get, ms or us. Do we need to add some
new attribute as flag or version? Or we need to increase
TCP_METRICS_GENL_VERSION in kernel and to check it in
process_msg ?

> -		tcp_metric_set_msecs(tm, TCP_METRIC_RTTVAR, var);
> +		tcp_metric_set(tm, TCP_METRIC_RTTVAR, var);

Regards

--
Julian Anastasov <ja@ssi.bg>

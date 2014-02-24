From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next] tcp: switch rtt estimations to usec
 resolution
Date: Mon, 24 Feb 2014 14:19:24 -0800
Message-ID: <1393280364.2316.79.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393137487.2316.48.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LFD.2.11.1402230908210.1460@ja.home.ssi.bg>
	 <1393178122.2316.50.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393181458.2316.56.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393216927.2316.62.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393266251.2316.68.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuchung Cheng <ycheng@google.com>, netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Larry Brakmo <brakmo@google.com>, Julian Anastasov <ja@ssi.bg>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:64897 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581AbaBXWT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 17:19:28 -0500
Received: by mail-pa0-f42.google.com with SMTP id kl14so7205023pab.1
        for <netdev@vger.kernel.org>; Mon, 24 Feb 2014 14:19:28 -0800 (PST)
In-Reply-To: <1393266251.2316.68.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-02-24 at 10:24 -0800, Eric Dumazet wrote:


> index d547075d8300..8e4c43d80784 100644
> --- a/net/ipv4/tcp_metrics.c
> +++ b/net/ipv4/tcp_metrics.c

...

> -	if (crtt > tp->srtt) {
> +	if (crtt > tp->srtt_us) {
>  		/* Set RTO like tcp_rtt_estimator(), but from cached RTT. */
>  		crtt >>= 3;
> -		inet_csk(sk)->icsk_rto = crtt + max(2 * crtt, tcp_rto_min(sk));
> -	} else if (tp->srtt == 0) {

This part is buggy it needs to be :

	crtt /= 8 * USEC_PER_MSEC;
	inet_csk(sk)->icsk_rto = crtt + max(2 * crtt, tcp_rto_min(sk));

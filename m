From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: switch rtt estimations to usec resolution
Date: Sun, 23 Feb 2014 09:55:22 -0800
Message-ID: <1393178122.2316.50.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393137487.2316.48.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LFD.2.11.1402230908210.1460@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Larry Brakmo <brakmo@google.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:52162 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbaBWRzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Feb 2014 12:55:25 -0500
Received: by mail-pa0-f48.google.com with SMTP id kx10so5554700pab.35
        for <netdev@vger.kernel.org>; Sun, 23 Feb 2014 09:55:24 -0800 (PST)
In-Reply-To: <alpine.LFD.2.11.1402230908210.1460@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-02-23 at 09:36 +0200, Julian Anastasov wrote:
> 	Hello,
> 
> On Sat, 22 Feb 2014, Eric Dumazet wrote:
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Upcoming congestion controls for TCP require usec resolution for RTT
> > estimations. Millisecond resolution is simply not enough these days.
> 
> ...
> 
> > --- a/net/ipv4/tcp_metrics.c
> > +++ b/net/ipv4/tcp_metrics.c
> 
> ...
> 
> > @@ -408,10 +395,10 @@ void tcp_update_metrics(struct sock *sk)
> >  	 */
> >  	if (!tcp_metric_locked(tm, TCP_METRIC_RTT)) {
> >  		if (m <= 0)
> > -			rtt = tp->srtt;
> > +			rtt = tp->srtt_us;
> >  		else
> >  			rtt -= (m >> 3);
> > -		tcp_metric_set_msecs(tm, TCP_METRIC_RTT, rtt);
> > +		tcp_metric_set(tm, TCP_METRIC_RTT, rtt);
> 
> 	What is the way to handle this change of
> resolution in TCP_METRICS_ATTR_VALS? The ip tool has
> code in ip/tcp_metrics.c process_msg() that needs to
> know what we get, ms or us. Do we need to add some
> new attribute as flag or version? Or we need to increase
> TCP_METRICS_GENL_VERSION in kernel and to check it in
> process_msg ?

crap... This should have been usec units as we did for tcp_info years
ago.

Solution is to add TCP_METRIC_RTT_US and TCP_METRIC_RTTVAR_US attributes

I'll send a v2

Thanks !

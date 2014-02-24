From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] tcp: switch rtt estimations to usec
 resolution
Date: Mon, 24 Feb 2014 09:58:08 -0800
Message-ID: <1393264688.2316.65.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393137487.2316.48.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LFD.2.11.1402230908210.1460@ja.home.ssi.bg>
	 <1393178122.2316.50.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393181458.2316.56.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393216927.2316.62.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuchung Cheng <ycheng@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Larry Brakmo <brakmo@google.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:58424 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752985AbaBXR6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 12:58:10 -0500
Received: by mail-pd0-f176.google.com with SMTP id w10so6579504pde.7
        for <netdev@vger.kernel.org>; Mon, 24 Feb 2014 09:58:10 -0800 (PST)
In-Reply-To: <1393216927.2316.62.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-02-23 at 20:42 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Upcoming congestion controls for TCP require usec resolution for RTT
> estimations. Millisecond resolution is simply not enough these days.
> ---
> v3: Also use usec resolution for samples provided by SACK, as Yuchung
> suggested. (I was planning to do this as a followup, but it seems
> better to do a single change)

I'll send a v4, switching to ktime_get() instead of ktime_get_real(),
because we need to be resistant to a change of time on the host,
notably for further changes (min_rtt and a change of TCP timestamp
resolution)

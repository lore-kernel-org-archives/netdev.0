From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net] tcp: randomize timestamps on syncookies
Date: Fri, 5 May 2017 02:24:56 +0200
Message-ID: <20170505002456.GH13320@breakpoint.cc>
References: <1493935361.7796.29.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
        Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:59232 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750742AbdEEAZT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 20:25:19 -0400
Content-Disposition: inline
In-Reply-To: <1493935361.7796.29.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Whole point of randomization was to hide server uptime, but an attacker
> can simply start a syn flood and TCP generates 'old style' timestamps,
> directly revealing server jiffies value.
> 
> Also, TSval sent by the server to a particular remote address vary depending
> on syncookies being sent or not, potentially triggering PAWS drops for
> innocent clients.
> 
> Lets implement proper randomization, including for SYNcookies.
> 
> Also we do not need to export sysctl_tcp_timestamps, it is not used from
> a module.

I like the direction, but this is incomplete.

>  	if (want_cookie) {
>  		isn = cookie_init_sequence(af_ops, sk, skb, &req->mss);
> -		tcp_rsk(req)->ts_off = 0;

This breaks syncookies w. timestamps; cookie_timestamp_decode() lacks a tsoff
for readjustment.

We also need to pass the (recomputed) tsoff to tcp_get_cookie_sock().

Other than this, this patch looks good to me, thanks!

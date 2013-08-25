From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: TSO packets automatic sizing
Date: Sat, 24 Aug 2013 19:52:09 -0700
Message-ID: <1377399129.8828.87.camel@edumazet-glaptop>
References: <1377304192.8828.43.camel@edumazet-glaptop>
	 <20130824.224644.683932175468680609.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com,
	vanj@google.com, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:49666 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755074Ab3HYCwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Aug 2013 22:52:11 -0400
Received: by mail-pa0-f53.google.com with SMTP id lb1so2114684pab.26
        for <netdev@vger.kernel.org>; Sat, 24 Aug 2013 19:52:10 -0700 (PDT)
In-Reply-To: <20130824.224644.683932175468680609.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-08-24 at 22:46 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 23 Aug 2013 17:29:52 -0700
> 
> > After hearing many people over past years complaining against TSO being
> > bursty or even buggy, we are proud to present automatic sizing of TSO
> > packets.
> 
> Looks great.
> 
> > +	pr_debug("cwnd %u packets_out %u srtt %u -> rate = %llu bits\n",
> > +		 tp->snd_cwnd, tp->packets_out,
> > +		 jiffies_to_usecs(tp->srtt) >> 3, rate << 3);
> 
> I'd suggest you remove this though.
> 

Sure, but I found this very useful while debugging sch_fq.

CTRL=/sys/kernel/debug/dynamic_debug/control
echo "func tcp_rtt_estimator +p" >$CTRL
./netperf -l -1000000 -H lpq84
echo "func tcp_rtt_estimator -p" >$CTRL 

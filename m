From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 2/2] net: netem: always adjust now/delay when not
 reordering
Date: Wed, 21 Aug 2013 06:30:24 -0700
Message-ID: <1377091824.4226.102.camel@edumazet-glaptop>
References: <1377030800.4226.89.camel@edumazet-glaptop>
	  <1377064785-12629-1-git-send-email-mailings@hupie.com>
	 <1377065647.4226.96.camel@edumazet-glaptop> <5214668E.504@hupie.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ferry Huberts <mailings@hupie.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:39177 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab3HUNa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 09:30:26 -0400
Received: by mail-pd0-f179.google.com with SMTP id v10so452499pde.38
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 06:30:25 -0700 (PDT)
In-Reply-To: <5214668E.504@hupie.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-21 at 09:04 +0200, Ferry Huberts wrote:
> 
> On 21/08/13 08:14, Eric Dumazet wrote:
> > On Wed, 2013-08-21 at 07:59 +0200, Ferry Huberts wrote:
> >> From: Ferry Huberts <ferry.huberts@pelagic.nl>
> >>
> >> Not doing this (current behaviour) introduces reordering.
> >>
> >> The packet_len_2_sched_time call is the only thing that logically
> >> depends on q->rate, so move the now/delay adjustment out of the if.
> >>
> >> How to test:
> >> -----------
> > 
> > I ask again :
> > 
> > Did you test a config with both rate limiting and delay.
> 
> (sorry for missing that question)
> 
> Just did so and with rate limiting I get no reordering, which is logical
> looking at the code.
> 
> The thing is, the evaluation q->rate is within the 'no-reordering' block
> and in the current situation you can get reordering (with that 'strange'
> command). My patch makes sure that no reordering will occur, and
> effectively 'clamps' the realised delay, which currently isn't done.


OK, let me be very clear.

I would like you post the results of regression tests, to make sure that
you do not add a new regression.

It seems that you want _us_ to check all this for you.

With "rate 1Mbits delay 100ms 10ms", and ping probes sent every 100ms,
the pong reply of _all_ probes should be between 90ms and 110ms

Is it still the case after your patch ?

Thanks

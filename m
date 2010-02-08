From: jamal <hadi@cyberus.ca>
Subject: Re: rps: question
Date: Mon, 08 Feb 2010 10:09:08 -0500
Message-ID: <1265641748.3688.56.camel@bigi>
References: <1265568122.3688.36.camel@bigi>
	 <65634d661002072158r48ec15cag1ca58e704114a358@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	robert@herjulf.net, David Miller <davem@davemloft.net>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f223.google.com ([209.85.218.223]:56856 "EHLO
	mail-bw0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120Ab0BHPJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 10:09:14 -0500
Received: by bwz23 with SMTP id 23so1203719bwz.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2010 07:09:11 -0800 (PST)
In-Reply-To: <65634d661002072158r48ec15cag1ca58e704114a358@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-02-07 at 21:58 -0800, Tom Herbert wrote:

> I don't have specific numbers, although we are using this on
> application doing forwarding and numbers seem in line with what we see
> for an end host.
> 

When i get the chance i will give it a run. I have access to an i7
somewhere. It seems like i need some specific nics?

> No, the cost of the IPIs hasn't been an issue for us performance-wise.
>  We are using them extensively-- up to one per core per device
> interrupt.

Ok, so you are not going across cores then? I wonder if there's
some new optimization to reduce IPI latency  when both sender/receiver
reside on the same core? 

> We're calling __smp_call_function_single which is asynchronous in that
> the caller provides the call structure and there is not waiting for
> the IPI to complete.  A flag is used with each call structure that is
> set when the IPI is in progress, this prevents simultaneous use of a
> call structure.

It is possible that is just an abstraction hiding the details..
AFAIK, IPIs are synchronous. Remote has to ack with another IPI 
while the issuing cpu waits for ack IPI and then returns.

> I haven't seen any architectural specific issues with the IPIs, I
> believe they are completing in < 2 usecs on platforms we're running
> (some opteron systems that are over 3yrs old).

2 usecs aint bad (at 10G you only accumulate a few packets while
stalled). I think we saw much higher values.
I was asking on different architectures because I have tried something
equivalent as recent as 2 years back on a MIPS multicore and the
forwarding results were horrible. 
IPIs flush the processor pipeline so they aint cheap - but that may
vary depending on the architecture. Someone more knowledgeable should
be able to give better insights.
My suspicion is that with low transaction rate (with appropriate traffic
patterns) you will see a very much increased latency since you will 
be sending more IPIs..

cheers,
jamal


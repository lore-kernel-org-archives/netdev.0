From: jamal <hadi@cyberus.ca>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Thu, 15 Apr 2010 07:55:28 -0400
Message-ID: <1271332528.4567.150.camel@bigi>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi>
	 <20100415.014857.168270765.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, xiaosuo@gmail.com,
	andi@firstfloor.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f189.google.com ([209.85.221.189]:53194 "EHLO
	mail-qy0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142Ab0DOMGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 08:06:33 -0400
Received: by qyk27 with SMTP id 27so1541671qyk.23
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 05:06:32 -0700 (PDT)
In-Reply-To: <20100415.014857.168270765.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-15 at 01:48 -0700, David Miller wrote:

> A single-queue NIC is actually not a requirement, 
> RPS helps also in cases where you have 'N' application threads 
> and N is less than the number of CPUs your multi-queue NIC is 
> distributing traffic to.

sure..

> Moving the bulk of the input packet processing to the cpus where
> the applications actually sit had a non-trivial benefit.  

This is true regardless of rps though. 

> RFS takes this aspect to yet another level.

rfs looks quiet interesting;-> I think with some twist it could be
used with multiqueue nics as well

> I think for the case where application locality is important,
> RPS/RFS can help regardless of cache details.

Generally true, as long as there's not much shared data across the cpus
or the cost of a cache miss is reasonably tolerable. The socket layer
just happens to be not sharing much with ingress packet path and
for a single processor Nehalem, the caching system works so well that
the cost of cache misses is not as an important a variable. Everything
is on the same die including the MM controller etc.
I am speculating (didnt get any answer to the question i asked) that
people running rps use such hardware;->

I speculate again that it may be too costly to run rps on something like
a tigerton or intel clovertown where you have cores sharing/contending
for an FSB. If I can get answers to the question: "What h/ware are
people running?" i could be proven wrong.
[Note: I am not against RPS - i think it has its place; so i hope my
desire to find out when to use rps doesnt show as hostility towards
rps.]

cheers,
jamal


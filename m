From: Michal Soltys <soltys@ziu.info>
Subject: Re: [PATCH/RFC 00/11] HFSC patches
Date: Sat, 05 Nov 2011 18:43:11 +0100
Message-ID: <4EB575AF.1010903@ziu.info>
References: <1320460377-8682-1-git-send-email-soltys@ziu.info> <4EB4B1F0.20404@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:2336 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753831Ab1KERnK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Nov 2011 13:43:10 -0400
In-Reply-To: <4EB4B1F0.20404@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-11-05 04:48, Patrick McHardy wrote:
>
> Thanks Michal. It has been quite a while since I've last looked
> at this and this is complicated stuff, please give me a few days
> to review your patches.

Of course, and thanks for doing it. If I have any corrections, I'll add 
them as v2 versions in this thread (under respective patches).

>
>>  Apart from these, there's still one subtle thing to do w.r.t. cl_cvtmin (during
>>  init_vf(), as this value is lagged relatively to the situation at the time of
>>  enqueue).
>>
>>  On a side note, I was thinking about something like hfsc-strict or so - where
>>  [uplink] interface could be upperlimited on hfsc qdisc level, but all the class
>>  upperlimit would be otherwise gone. Not sure if anyone would be even interested
>>  in something like that at all.
>
> So classes would just use link-sharing curves? That's
> already possible, so I probably don't get your idea.
>

I mean, that upperlimit's main use is for matching [upstream] router's 
capability (as far as I've always seen this). Other scenarios where 
upperlimit is used somewhere lower, can be transformed to just proper 
linksharing ratios and realtime leaves w/o linksharking part (if 
applicable) - so thus the idea of no upperlimit at class level at all 
(and related code), but ability to define one at qdisc level (added 
during tc qdisc add hfsc ...) and executed during hfsc_dequeue().

Note - this is just a purist's idea, and I realize unacceptable in 
context of existing hfsc scheduler for many reasons (compatibility with 
exisiting configurations for once). But the idea about 
hfsc-{light,strict,pure,etc.} has been crawling in my head for a while.


Apart from that - in the sch_hfsc.c code there're few things you once 
commented out - related to myf adjustments that "overshoot" and made 
classes stay way too much under their respective linksharing curves. Do 
you have the configuration examples saved somewhere, under which it 
happened ?

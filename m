From: Harout Hedeshian <harouth@codeaurora.org>
Subject: Re: TCP: Support configurable delayed-ack parameters
Date: Fri, 28 Feb 2014 09:37:42 -0700
Message-ID: <5310BB56.6060208@codeaurora.org>
References: <00e801cf3497$c37255f0$4a5701d0$@codeaurora.org> <1393602573.26794.65.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:39952 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752155AbaB1Qhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 11:37:55 -0500
In-Reply-To: <1393602573.26794.65.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/28/2014 08:49 AM, Eric Dumazet wrote:
> On Fri, 2014-02-28 at 08:14 -0700, Harout Hedeshian wrote:
>> Hello David,
>>
>> I found a thread from June 2012 (subject matches this email) discussing the
>> addition of parameters to manually tune the delayed TCP ACK parameters, and
>> add new TCP socket options for application specific tuning. The patch in
>> question would multiply the receive mss by some constant exposed in /proc.
>> We have experimented with a similar approach and found significant
>> improvements in performance when asymmetric links are utilized; specifically
>> where the hardware is limited in egress packets/sec (but not raw bandwidth).
>> As an example, in one test we saw a 100% improvement when doing rcv_mss*4.
>
> Note that we have some bugs in TCP stack, that might explain the
> behavior. Please post pcap so that we can really understand your point,
> and eventually pinpoint bugs.
>
> For example TSO should_defer() is known to be problematic, and we have a
> patch fixing the issue. I'll post it today.
>
> Other bugs included a problem in TCP Small Queue, that was recently
> fixed.
>
>
>

Hi Eric,

Disclaimer before I waste peoples' time on a ghost chase: This is running on non-x86 custom hardware where there may be buggy drivers or implementation. Also, 
we are running on 3.10.0 and are unable to move to a newer kernel for reasons beyond my control.

I will capture pcap logs showing the TCP stream under standard configuration, and with mss*4. That said, sharing will be a problem as these files even with 
limited capture size can be several hundred MB (of course attaching to the email won't work).

I will keep an eye out for the should_defer() patch today. I would also appreciate if you could point me to the TCP Small Queue patch. I would like to pull 
these into my build and give them a shot.

Harout

-- 
Harout Hedeshian

Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, hosted by The Linux Foundation

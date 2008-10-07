From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Possible regression in HTB
Date: Wed, 8 Oct 2008 00:00:22 +0200
Message-ID: <20081007220022.GA2664@ami.dom.local>
References: <48EB5A92.6010704@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Martin Devera <devik@cdi.cz>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:27684 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755679AbYJGV6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 17:58:42 -0400
Received: by ug-out-1314.google.com with SMTP id k3so384481ugf.37
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2008 14:58:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48EB5A92.6010704@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote, On 10/07/2008 02:48 PM:

> Jarek Poplawski wrote:
>>>> Prior to this patch the result looks like this:
>>>>
>>>> 10194: 545134589bits/s 545Mbits/s
>>>> 10197: 205358520bits/s 205Mbits/s
>>>> 10196: 205311416bits/s 205Mbits/s
>>>> -----------------------------------
>>>> total: 955804525bits/s 955Mbits/s
>>>>
>>>> And after the patch the result looks like this:
>>>> 10194: 384248522bits/s 384Mbits/s
>>>> 10197: 284706778bits/s 284Mbits/s
>>>> 10196: 288119464bits/s 288Mbits/s
>>>> -----------------------------------
>>>> total: 957074765bits/s 957Mbits/s
> 
> I've misinterpreted the numbers, please disregard my previous mail.
> 
> I'm wondering though, even before this patch, the sharing doesn't
> seem to be proportional to the allocated rates. Assuming the upper
> limit is somewhere around 950mbit, we have 250 mbit for sharing
> above the allocated rates, so it should be:
> 
> 500mbit class: 500mbit + 250mbit/7*5 == 678.57mbit
> 100mbit class: 100mbit + 250mbit/1*5 == 150mbit
> 100mbit class: 100mbit + 250mbit/1*5 == 150mbit
> 
> But maybe my understanding of how excess bandwidth is distributed
> with HTB is wrong.

Good point, but the numbers a bit wrong:

500mbit class: 500mbit + 250mbit/7*5 == 678.57mbit
100mbit class: 100mbit + 250mbit/7*1 == 135.71mbit
100mbit class: 100mbit + 250mbit/7*1 == 135.71mbit
					==========
					950.00mbit

> 
> I still can't really make anything of this bug, but the only two
> visible differences to HTB resulting from requeing on an upper level
> should be that
> 
> 1) it doesn't reactivate classes that went passive by the last dequeue
> 2) the time checkpoint from the last dequeue event is different
> 
> I guess its in fact the second thing, if a lower priority packet
> is requeued and dequeued again, HTB doesn't notice and might allow
> the class to send earlier again than it would have previously.

With high requeuing the timing has to be wrong, but I'm not sure why
just lower priority has to gain here.

Anyway, IMHO this regression is really doubtful: since the digits are
wrong in both cases I can only agree the old method gives better wrong
results...

Jarek P.

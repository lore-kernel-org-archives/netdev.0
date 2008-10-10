From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Possible regression in HTB
Date: Fri, 10 Oct 2008 06:59:34 +0000
Message-ID: <20081010065934.GA4762@ff.dom.local>
References: <20081007220022.GA2664@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Martin Devera <devik@cdi.cz>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:42483 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbYJJG7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 02:59:43 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1196850ugf.37
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2008 23:59:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081007220022.GA2664@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08-10-2008 00:00, Jarek Poplawski wrote:
> Patrick McHardy wrote, On 10/07/2008 02:48 PM:
...
>> I still can't really make anything of this bug, but the only two
>> visible differences to HTB resulting from requeing on an upper level
>> should be that
>>
>> 1) it doesn't reactivate classes that went passive by the last dequeue
>> 2) the time checkpoint from the last dequeue event is different
>>
>> I guess its in fact the second thing, if a lower priority packet
>> is requeued and dequeued again, HTB doesn't notice and might allow
>> the class to send earlier again than it would have previously.
> 
> With high requeuing the timing has to be wrong, but I'm not sure why
> just lower priority has to gain here.

I think it's quite simple and not hypothetical: lower priority classes
gain on overestimated ceils not on requeuing. Because of lending over
hardware limit all buckets get more tokens than their rate, and they
are allowed to send more and more until the hardware stops. HTB still
doesn't know about this and it can lend until mbuffer limit is reached.
So at some moment all buffers are full, everyone can send (bigger
buffers could still give some advantage) and everything is controlled
only by hardware. This is clear gain for the less privileged.

Requeuing actually can prevent this some way, which IMHO, shouldn't
matter here because it's not the way intended to shape the traffic.

But we could consider if, after removing requeuing which mattered
here, some change is needed in "proper" way of limiting such effects
of wrong parameters or hardware errors (like the size of mbuffer etc.)?

Thanks,
Jarek P.

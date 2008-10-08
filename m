From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Possible regression in HTB
Date: Wed, 8 Oct 2008 08:53:25 +0000
Message-ID: <20081008085325.GF4174@ff.dom.local>
References: <48EB5A92.6010704@trash.net> <20081007220022.GA2664@ami.dom.local> <20081008002153.GL12021@verge.net.au> <48EBFF5E.1090902@trash.net> <48EC0190.7040804@trash.net> <48EC6286.1030202@cdi.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Martin Devera <devik@cdi.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:27742 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474AbYJHIxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 04:53:33 -0400
Received: by ey-out-2122.google.com with SMTP id 6so1191159eyi.37
        for <netdev@vger.kernel.org>; Wed, 08 Oct 2008 01:53:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48EC6286.1030202@cdi.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 08, 2008 at 09:34:30AM +0200, Martin Devera wrote:
> Patrick McHardy wrote:
>> Patrick McHardy wrote:
>>> So what would really be useful to understand this is to make HTB
>>> control the queue and see if it behaves as expected. 
>>
>> What also might help understand this better would be some
>> runtime data. An easy way to get some halfway usable data
>> is to just run
>>
>> tc -s -d qdisc show dev ...; tc -s -d class show dev ...
>>
>> in a loop.
>
> IMHO there is problem with packet hold outside of the qdisc.
> HTB like other non-workconserving qdiscs rely on information
> about class backlogged state.
> When there is packet in a queue then the queue is active (has
> a demand to send).
> The algorithm samples queue states at deterministic but unregular
> intervals to see whose classes wants service and whose can lend.
>
> If you hold a packet outside, relevant class thinks that it is
> not backlogged - and if sampled at this time then the algorithm
> decides to lend classe's time.

Right, but on the other hand I can't see any correction of these
times/tokens, so it seems this can't give us "right" results
anyway? E.g. with 100% requeuing (each packet requeued once) HTB
should think it "gave" the rate 2x higher than seen on the other
side - or I miss something?

>
> And because the most active class has the biggest probability
> to see its packet catched outside, as final effect all classes
> will end up equalized with (almost) the same rates.

Yes, but if this most active class has always packets in its
queue, and is most prioritized, it seems this should get its
share anyway.

>
> Thus, from qdisc point, it is not good to keep a packet for
> more time out of the qdisc.

Sure, the question is how much it's useful against associated
code complications and additional cpu usage.

Thanks,
Jarek P.

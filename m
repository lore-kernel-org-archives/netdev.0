From: Martin Devera <devik@cdi.cz>
Subject: Re: Possible regression in HTB
Date: Wed, 08 Oct 2008 09:34:30 +0200
Message-ID: <48EC6286.1030202@cdi.cz>
References: <48EB5A92.6010704@trash.net> <20081007220022.GA2664@ami.dom.local> <20081008002153.GL12021@verge.net.au> <48EBFF5E.1090902@trash.net> <48EC0190.7040804@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>,
	Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.wifcom.cz ([89.185.251.8]:53578 "EHLO wifcom.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753755AbYJHIJp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 04:09:45 -0400
In-Reply-To: <48EC0190.7040804@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Patrick McHardy wrote:
>> So what would really be useful to understand this is to make HTB
>> control the queue and see if it behaves as expected. 
> 
> What also might help understand this better would be some
> runtime data. An easy way to get some halfway usable data
> is to just run
> 
> tc -s -d qdisc show dev ...; tc -s -d class show dev ...
> 
> in a loop.

IMHO there is problem with packet hold outside of the qdisc.
HTB like other non-workconserving qdiscs rely on information
about class backlogged state.
When there is packet in a queue then the queue is active (has
a demand to send).
The algorithm samples queue states at deterministic but unregular
intervals to see whose classes wants service and whose can lend.

If you hold a packet outside, relevant class thinks that it is
not backlogged - and if sampled at this time then the algorithm
decides to lend classe's time.

And because the most active class has the biggest probability
to see its packet catched outside, as final effect all classes
will end up equalized with (almost) the same rates.

Thus, from qdisc point, it is not good to keep a packet for
more time out of the qdisc.

devik

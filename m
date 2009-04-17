From: David Miller <davem@davemloft.net>
Subject: Re: An inconsistency/bug in ingress netem timestamps
Date: Fri, 17 Apr 2009 05:04:22 -0700 (PDT)
Message-ID: <20090417.050422.134655407.davem@davemloft.net>
References: <20090416.031034.41207844.davem@davemloft.net>
	<20090416214846.GA9375@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexandre.sidorenko@hp.com, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55192
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753463AbZDQMEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 08:04:30 -0400
In-Reply-To: <20090416214846.GA9375@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 16 Apr 2009 23:48:46 +0200

> David Miller wrote, On 04/16/2009 12:10 PM:
> 
>> Since IFB completely bypasses netif_rx() and netif_receive_skb() I
>> think it should unconditionally set skb->tstamp.tv64 to zero and
>> invoke net_timestamp()
> 
> IFB calls netif_rx() and I don't understand why do we need to update
> tstamp again except for this netem case.
> 
>> This would match the behavior of loopback and tunnels, and in my
>> opinion this is reasonable.  There will be virtually no overhead
>> added unless timestamping is enabled via ping or similar, and in
>> return we get what I think is correctness :-)
> 
> I think we need some consistency in counting or not counting packet
> scheduling delays into timestamps. Anyway we should avoid unnecessary
> updates like now, so I'm proposing something different (for testing).

Ok, now I understand this situation even more clearly, thanks
Jarek.

I think your patch is the most palatable solution I've seen
so far, but I want to consider it some more.

Meanwhile, Alexandre can you test Jarek's patch for your case?

Thanks!

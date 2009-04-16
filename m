From: David Miller <davem@davemloft.net>
Subject: Re: An inconsistency/bug in ingress netem timestamps
Date: Thu, 16 Apr 2009 03:10:34 -0700 (PDT)
Message-ID: <20090416.031034.41207844.davem@davemloft.net>
References: <20090415195022.GA3322@ami.dom.local>
	<200904151610.43980.alexandre.sidorenko@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: alexandre.sidorenko@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50694
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752464AbZDPKKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 06:10:43 -0400
In-Reply-To: <200904151610.43980.alexandre.sidorenko@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Sidorenko <alexandre.sidorenko@hp.com>
Date: Wed, 15 Apr 2009 16:10:43 -0400

> On April 15, 2009 03:50:22 pm Jarek Poplawski wrote:
> 
>> Isn't it when act_mirred calls dev_queue_xmit with dev_queue_xmit_nit?
>> But, as above mentioned, I doubt it's "updated properly" in this case.
> 
> I can see that dev_queue_xmit_nit calls net_timestamp(skb) unconditionally. I 
> agree that to fix this properly we need to update tstamp in another place 
> explicitly (in ifb or netem?).

Since IFB completely bypasses netif_rx() and netif_receive_skb() I
think it should unconditionally set skb->tstamp.tv64 to zero and
invoke net_timestamp()

This would match the behavior of loopback and tunnels, and in my
opinion this is reasonable.  There will be virtually no overhead
added unless timestamping is enabled via ping or similar, and in
return we get what I think is correctness :-)

This also means we need to export net_timestamp() to modules.

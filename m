From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] remove claim balance_rr won't reorder on many to one
Date: Tue, 30 Oct 2007 18:02:05 -0700
Message-ID: <4727D40D.8050202@hp.com>
References: <200710301948.MAA04351@tardy.cup.hp.com> <5242.1193777750@death>	<4727AC42.2060709@hp.com> <19779.1193790169@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:35647 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752914AbXJaBCH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 21:02:07 -0400
In-Reply-To: <19779.1193790169@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> Rick Jones <rick.jones2@hp.com> wrote:
> 
> 
>>I have to wonder if the full description of the different versions of
>>being a little bit pregnant is worth it.  Just saying that using
>>balance-rr will result in reordering seems much more simple to comprehend.
> 
> 
> 	True, but the different configurations produce very different
> levels of reordering.
> 
> 	There seem to be users out there trying to use balance-rr to
> maximize single stream TCP throughput (even with reordering), so I think
> the relative badness information is worthwhile.

I will admit to coming from an "if you want a single stream to go faster buy the 
next higher speed NIC" point of view, which means I pretty much lump all the 
degrees of reordering badness together.

The relative badness though is likely a _very_ broad space which couldn't be 
covered adequately in just a paragraph or two.  Notice how long my email 
describing my one experiment ended-up.

For example, I suspect, but have not verified that the one way one might get 
minimal reordering with many to one would be to have a sender with the many 
interfaces slow enough to not be able to get ahead of the sum of the NICs in the 
bond, so the transmit queues all remain at 0, coupled perhaps with NICs all in 
equal-speed and equal-feed I/O slots.

Start to be able to keep ahead of one or more of the NICs and soon we are 
starting along a rather long continuum which includes whether there are other 
concurrent connections, the distribution of send() sized by the applications, 
whether or not various offloads are enabled etc etc etc...

>>Also, since balance-rr is strictly an outbound policy, does case three
>>even enter into it - as you say, that will be up to the switch, which will
>>be doing whatever it was told or felt like doing regardless of balance-rr
>>on the bond in the host.
> 
> 
> 	Point three provides an answer to a question I've been asked
> pretty regularly by customers, so I think it's good information.

But since it isn't specific to balance_rr it would seem better placed in a 
"Switch Considerations" or "Inbound Considerations" section?

>>Even better would be to be able to start to move away from "etherchannel"
>>towards the de jure standard's terms, whatever the heck they are :)
> 
> 
> 	I believe that EtherChannel is the standard term for what we're
> talking about here, but it's a Cisco trademark.  I'd guess that most
> switch vendors don't come right out and call their "EtherChannel(tm)
> compatible" mode exactly that; they call it something else, but it's
> still meant to be compatible with EtherChannel.

Well, that assumes that many switch vendors are still including EtherChannel.  I 
know of at least one non-trivial switch vendor which has consolidated on 
LACP/802.3ad.  When that vendor was supporting EtherChannel, they called it such.

rick jones

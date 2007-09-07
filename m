From: James Chapman <jchapman@katalix.com>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
 low traffic rates
Date: Fri, 07 Sep 2007 10:38:15 +0100
Message-ID: <46E11C07.50307@katalix.com>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com> <20070907035528.GA3755@ludhiana>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, davem@davemloft.net,
	jeff@garzik.org, ossthema@de.ibm.com,
	Stephen Hemminger <shemminger@osdl.org>
To: Mandeep Singh Baines <mandeep.baines@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:51661 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965051AbXIGJiT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 05:38:19 -0400
In-Reply-To: <20070907035528.GA3755@ludhiana>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Mandeep,

Mandeep Singh Baines wrote:
> Hi James,
> 
> I like the idea of staying in poll longer.
> 
> My comments are similar to what Jamal and Stephen have already said.
> 
> A tunable (via sysfs) would be nice.
> 
> A timer might be preferred to jiffy polling. Jiffy polling will not increase 
> latency the way a timer would. However, jiffy polling will consume a lot more
> CPU than a timer would. Hence more power. For jiffy polling, you could have 
> thousands of calls to poll for a single packet received. While in a timer 
> approach the numbers of polls per packet is upper bound to 2. 

Why would using a timer to hold off the napi_complete() rather than 
jiffy count limit the polls per packet to 2?

> I think it may difficult to make poll efficient for the no packet case because,
> at a minimum, you have to poll the device state via the has_work method.

Why wouldn't it be efficient? It would usually be done by reading an 
"interrupt pending" register.

> If you go to a timer implementation then having a tunable will be important.
> Different appications will have different requirements on delay and jitter.
> Some applications may want to trade delay/jitter for less CPU/power 
> consumption and some may not.

I agree. I'm leaning towards a new ethtool parameter to control this to 
be consistent with other per-device tunables.

> imho, the work should definately be pursued further:)

Thanks Mandeep. I'll try. :)

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development


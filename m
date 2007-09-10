From: James Chapman <jchapman@katalix.com>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
 low traffic rates
Date: Mon, 10 Sep 2007 10:33:34 +0100
Message-ID: <46E50F6E.5010503@katalix.com>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com> <20070907035528.GA3755@ludhiana> <46E11C07.50307@katalix.com> <20070908164222.GB3765@ludhiana>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, davem@davemloft.net,
	jeff@garzik.org, ossthema@de.ibm.com,
	Stephen Hemminger <shemminger@osdl.org>
To: Mandeep Singh Baines <mandeep.baines@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:40876 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751204AbXIJJdi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2007 05:33:38 -0400
In-Reply-To: <20070908164222.GB3765@ludhiana>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mandeep Singh Baines wrote:
>> Why would using a timer to hold off the napi_complete() rather than 
>> jiffy count limit the polls per packet to 2?
>>
> I was thinking a timer could be used in the way suggested in Jamal's
> paper. The driver would do nothing (park) until the timer expires. So
> there would be no calls to poll for the duration of the timer. Hence,
> this approach would add extra latency not present in a jiffy polling
> approach.

Ah, ok. I wasn't planning to test timer-driven polling. :)

>> Why wouldn't it be efficient? It would usually be done by reading an 
>> "interrupt pending" register.
>>
> Reading the "interrupt pending" register would require an MMIO read.
> MMIO reads are very expensive. In some systems the latency of an MMIO
> read can be 1000x that of an L1 cache access.

Agreed. Testing for any work being available should be as efficient as 
possible and would be driver specific.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development


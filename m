From: James Chapman <jchapman@katalix.com>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
 low traffic rates
Date: Wed, 12 Sep 2007 17:26:33 +0100
Message-ID: <46E81339.4080602@katalix.com>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com>	<1189120020.4259.68.camel@localhost>	<46E11A61.9030409@katalix.com>	<1189171370.4234.38.camel@localhost>	<20070912030428.16059af6.billfink@mindspring.com>	<1189599142.4326.38.camel@localhost>	<46E7EE89.9060006@katalix.com> <20070912160239.70a580e8@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Bill Fink <billfink@mindspring.com>,
	netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org,
	mandeep.baines@gmail.com, ossthema@de.ibm.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:39602 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765031AbXILQ07 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 12:26:59 -0400
In-Reply-To: <20070912160239.70a580e8@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Wed, 12 Sep 2007 14:50:01 +0100
> James Chapman <jchapman@katalix.com> wrote:
>> By low traffic, I assume you mean a rate at which the NAPI driver 
>> doesn't stay in polled mode. The problem is that that rate is getting 
>> higher all the time, as interface and CPU speeds increase. This results 
>> in too many interrupts and NAPI thrashing in/out of polled mode very 
>> quickly.
> 
> But if you compare this to non-NAPI driver the same softirq
> overhead happens. The problem is that for many older devices disabling IRQ's
> require an expensive non-cached PCI access. Smarter, newer devices
> all use MSI which is pure edge triggered and with proper register
> usage, NAPI should be no worse than non-NAPI.

While MSI is good, the CPU interrupt overhead (saving/restoring CPU 
registers) can hurt bad, especially for RISC CPUs. When packet 
processing is interrupt-driven, the kernel's scheduler plays second 
fiddle to hardware interrupt and softirq scheduling. Even super-priority 
real-time threads don't get a look in.

When traffic rates cause 1 interrupt per tx/rx packet event, NAPI will 
use more CPU and have higher latency than non-NAPI because of the extra 
work done to enter and leave polled mode. At higher packet rates, NAPI 
works very well, unlike non-NAPI which usually needs hardware interrupt 
mitigation to avoid interrupt live-lock.

I think NAPI should be a _requirement_ for new net drivers. But I 
recognize that it has some issues, hence this thread.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development


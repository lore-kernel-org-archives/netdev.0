From: Rick Jones <rick.jones2@hp.com>
Subject: Re: "meaningful" spinlock contention when bound to non-intr CPU?
Date: Fri, 02 Feb 2007 10:17:47 -0800
Message-ID: <45C3804B.20604@hp.com>
References: <45C242C9.1010601@hp.com> <4807377b0702020847n11da1298ncdb5cf1609c8f0d2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:50881 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945995AbXBBSRs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 13:17:48 -0500
In-Reply-To: <4807377b0702020847n11da1298ncdb5cf1609c8f0d2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> SPINLOCKS         HOLD            WAIT
>>    UTIL  CON    MEAN(  MAX )   MEAN(  MAX )(% CPU)     TOTAL NOWAIT SPIN
>> RJECT  NAME
>>
>>    7.4%  2.8%  0.1us( 143us)  3.3us( 147us)( 1.4%)  75262432 97.2%  2.8%
>>     0%  lock_sock_nested+0x30
>>   29.5%  6.6%  0.5us( 148us)  0.9us( 143us)(0.49%)  37622512 93.4%  6.6%
>>     0%  tcp_v4_rcv+0xb30
>>    3.0%  5.6%  0.1us( 142us)  0.9us( 143us)(0.14%)  13911325 94.4%  5.6%
>>     0%  release_sock+0x120
>>    9.6% 0.75%  0.1us( 144us)  0.7us( 139us)(0.08%)  75262432 99.2% 0.75%
>>     0%  release_sock+0x30
>> ...
>> Still, does this look like something worth persuing?  In a past life/OS
>> when one was able to eliminate one percentage point of spinlock
>> contention, two percentage points of improvement ensued.
> 
> 
> Rick, this looks like good stuff, we're seeing more and more issues
> like this as systems become more multi-core and have more interrupts
> per NIC (think MSI-X)

MSI-X - haven't even gotten to that - discussion of that probably 
overlaps with some "pci" mailing list right?

> Let me know if there is something I can do to help.

I suppose one good step would be to reproduce the results on some other 
platform.  After that, I need to understand what those routines are 
doing much better than I currently do, particularly from an 
"architecture" perspective - I think that it may involve all the 
prequeue/try to get the TCP processing on the user's stack stuff but I'm 
_far_ from certain.

rick jones


From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC NET 00/02]: Secondary unicast address support
Date: Fri, 22 Jun 2007 02:08:49 +0200
Message-ID: <467B1311.6090001@trash.net>
References: <20070620180017.6685.70611.sendpatchset@localhost.localdomain>	<m13b0lf7mr.fsf@ebiederm.dsl.xmission.com>	<467ACDE1.7070907@trash.net> <m1sl8ldp6u.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	davem@davemloft.net, jeff@garzik.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49992 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090AbXFVAJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 20:09:16 -0400
In-Reply-To: <m1sl8ldp6u.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Patrick McHardy <kaber@trash.net> writes:
>
>   
>> Eric W. Biederman wrote:
>>     
>>> I'm trying to understand what the point of this patch is.
>>>
>>> In once sense I find the concept of filtering and listening for multiple
>>> mac addresses very interesting, especially if we could break out different
>>> streams of traffic by destination mac address into separate network devices.
>>> This would remove the need to any kind of ethernet tunnel and makes multiple
>>> network namespaces much more pleasant.
>>>
>>> However this just seems to allow a card to decode multiple mac addresses
>>> which in some oddball load balancing configurations may actually be
>>> useful, but it seems fairly limited.
>>>
>>> Do you have a specific use case you envision for this multiple mac
>>> functionality?
>>>
>>>       
>> Yes, please see the MACVLAN patch I posted one or two days earlier.
>>     
>
> Thanks.  That is what I was envisioning.  I keep suspecting one of
> the cool multi-rx queue nics my start doing some of the demux in hardware.
> But whatever if it works and is relatively fast it is good enough for me.
>   

When NICs support that I guess they the macvlan driver could be adapted
to take advantage of that.
>   
>> 8021q can also make use of it and Dave mentioned some virtualization
>> devices want this as well.
>>     
>
> Right makes sense.  And ethernet bridging (which is the general case
> of the virtualization Dave mentioned should also be able to take
> advantage of multiple unicast addresses).  So this definitely make
> sense.
>   


It needs promiscous mode to learn, so I'm not sure how much
this will help bridging.
> Have you done any performance testing with the macvlan code?  With
> the ethernet tunnel device we keep getting copied unicast packets on
> some path or other which slowed things down.  Simply not doing the
> firewalling until the packets have made it through the macvlan device
> should help here.
>   

Performance should be at least as good as on a bridge device since
the macvlan driver does basically nothing and uses the same functions
for receiving and sending packets.

> For the macvlan code do we need to do anything special if we transmit
> to a mac we would normally receive?  Another unicast mac of the same
> nic for example.

That doesn't happen under normal circumstances. I don't believe
it would work.

> For the macvlan hash you just use an upper byte.  Is that just a
> simple starting place, or do we not need a more complex hash.
>   


It comes from the original code, I think it should be good enough.


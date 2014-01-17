From: sohny thomas <sohny.kernel@gmail.com>
Subject: Re: ipv6: default route for link local address is not added while
 assigning a address
Date: Fri, 17 Jan 2014 14:04:26 +0530
Message-ID: <52D8EB12.6070901@gmail.com>
References: <52D2F201.1090903@gmail.com> <52D3A885.2080107@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net,
	kumuda <kumuda@linux.vnet.ibm.com>, hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:44950 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064AbaAQIed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 03:34:33 -0500
In-Reply-To: <52D3A885.2080107@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

Any updates on my reply, Any more info is required.
Can this be pulled into the kernel tree?

Thanks & Regards,
Sohny


On Monday 13 January 2014 02:19 PM, sohny thomas wrote:
> On Friday 10 January 2014 10:46 PM, Hannes Frederic Sowa wrote:
>> On Fri, Jan 10, 2014 at 05:33:08PM +0100, Nicolas Dichtel wrote:
>>> CC: netdev
>>>
>>> Le 10/01/2014 13:20, sohny thomas a =C3=A9crit :
>>>> Default route for link local address is configured automatically i=
f
>>>> NETWORKING_IPV6=3Dyes is in ifcfg-eth*.
>>>> When the route table for the interface is flushed and a new addres=
s is
>>>> added to
>>>> the same device with out removing linklocal addr, default route fo=
r
>>>> link
>>>> local
>>>> address has to added by default.
>>> I would say that removing the link local route but not the link loc=
al
>>> address
>>> is a configuration problem.
>>> If you remove a connected route but not the associated address, you=
 will
>>> have
>>> the same problem.
>> We have some user accessible routes that are essential for IPv6 stac=
k
>> to work at all. So I don't know if I can agree with that.
>>
>> Maybe flush is a bit too aggressive?
>>
> Hi ,
>
> Thank you for the inputs.
>
> In the test for ipv6 default address selection , we are testing the r=
ule
> 2 as specified in RFC 6724
>
>    If Scope(SA) < Scope(SB): If Scope(SA) < Scope(D), then prefer SB
>      and otherwise prefer SA.
>      Similarly, if Scope(SB) < Scope(SA): If Scope(SB) < Scope(D), th=
en
>      prefer SA and otherwise prefer SB.
>
> Test:
>
>    Check 04:
>       Destination: ff08::2(OS)
>       Candidate Source Addresses: fec0::1(SS) or LLA(LS)
>       Result: fec0::1(SS)
>
>       Scope(LLA) < Scope(fec0::1): If Scope(LLA) < Scope(ff08::2),  y=
es,
> prefer fec0::1
>
>
> Now in the test its flushing all the routes and adding an address ,
> which in causes to add route into the routing table including the lin=
k
> local routes.
> Earlier in 2.6.32 it used to work fine now due to the above mentioned
> check-in this is not happening
>
> Of course we can still just delete a route and add , but even if we
> delete the link local route, IMHO i think it should update the LLA ro=
ute
> when the interface is next added an address or bought up which ever i=
s
> the case.
>
> Regards,
> Sohny
>
>

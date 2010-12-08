From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: echo > 0 .../disable_ipv6 broken in 2.6.37-rc4
Date: Wed, 08 Dec 2010 13:29:52 -0800
Message-ID: <m14oaoeywf.fsf@fess.ebiederm.org>
References: <m17hfnlpe1.fsf@fess.ebiederm.org> <4CFD0AF0.9090809@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Mahesh Kelkar <maheshkelkar@gmail.com>,
	Lorenzo Colitti <lorenzo@google.com>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:58732 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676Ab0LHV35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 16:29:57 -0500
In-Reply-To: <4CFD0AF0.9090809@hp.com> (Brian Haley's message of "Mon, 06 Dec
	2010 11:10:24 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley <brian.haley@hp.com> writes:

> On 12/05/2010 07:24 PM, Eric W. Biederman wrote:
>> 
>> In 2.6.37-rc4 ipv6 can be disabled not enabled.
>> The last kernel I have tested and know this works on is 2.6.33.
>> 
>> To reproduce:
>>    ~ # ip link set lo up
>>    ~ # ping6 ::1
>>    PING ::1(::1) 56 data bytes
>>    64 bytes from ::1: icmp_seq=1 ttl=64 time=0.026 ms
>>    ^C
>>    --- ::1 ping statistics ---
>>    1 packets transmitted, 1 received, 0% packet loss, time 782ms
>>    rtt min/avg/max/mdev = 0.026/0.026/0.026/0.000 ms
>>    ~ # echo 1 > /proc/sys/net/ipv6/conf/lo/disable_ipv6 
>>    ~ # ping6 ::1
>>    connect: Network is unreachable
>>    ~ # echo 0 > /proc/sys/net/ipv6/conf/lo/disable_ipv6 
>>    ~ # ping6 ::1
>>    connect: Network is unreachable
>> 
>> 
>> I intend to poke at this a little more but at the moment
>> I am drawing a blank at what is going on.
>
> It should just be calling addrconf_notify() with either NETDEV_UP
> or NETDEV_DOWN.  Does the address not come back?  Or the route?

The address never went away, and I don't think we have a route to ::1.

Playing with this a little more if I delete the address and then bounce
the interface ping ::1 works again.  So something is just not getting
reinitialized.

Unfortunately I don't see anything obvious.  I'm still scratching my
head.

>> I intend to keep poking at this but if anyone can figure this out
>> before I do I would be greatly appreciative.
>
> I'm pulling the latest tree now, my 2.6.32.24 system is running fine, so
> it's something after that.

Agreed.  I don't have problems on 2.6.33 either, but because of overload
I haven't been doing regular testing of the kernels inbetween.

Eric

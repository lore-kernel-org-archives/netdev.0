From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [lxc-devel] Poor bridging performance on 10 GbE
Date: Thu, 19 Mar 2009 10:08:00 +0100
Message-ID: <49C20B70.7050509@fr.ibm.com>
References: <b30d1c3b0903180221h5175618eue162ffdec3817b4c@mail.gmail.com> <49C0C87B.7070507@fr.ibm.com> <b30d1c3b0903180856r6dce554ap35b8d6a3ee7829e0@mail.gmail.com> <m1wsamcp4n.fsf@fess.ebiederm.org> <b30d1c3b0903182237w7667c5bbt1ea098025f3b5f36@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.osdl.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	lxc-devel@lists.sourceforge.net
To: Ryousei Takano <ryousei@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:61366 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754618AbZCSJIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 05:08:09 -0400
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate7.uk.ibm.com (8.14.3/8.13.8) with ESMTP id n2J985Rl667308
	for <netdev@vger.kernel.org>; Thu, 19 Mar 2009 09:08:05 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2J985qj3404010
	for <netdev@vger.kernel.org>; Thu, 19 Mar 2009 09:08:05 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2J984xr015057
	for <netdev@vger.kernel.org>; Thu, 19 Mar 2009 09:08:04 GMT
In-Reply-To: <b30d1c3b0903182237w7667c5bbt1ea098025f3b5f36@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ryousei Takano wrote:
> Hi Eric,
> 
> On Thu, Mar 19, 2009 at 9:50 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
> 
> [snip]
> 
>> Bridging last I looked uses the least common denominator of hardware
>> offloads.  Which likely explains why adding a veth decreased your
>> bridging performance.
>>
> At least now LRO cannot coexist bridging.
> So I disable the LRO feature of the myri10ge driver.
> 
>>>>> Here is my experimental setting:
>>>>>        OS: Ubuntu server 8.10 amd64
>>>>>        Kernel: 2.6.27-rc8 (checkout from the lxc git repository)
>>>> I would recommend to use the 2.6.29-rc8 vanilla because this kernel does no
>>>> longer need patches, a lot of fixes were done in the network namespace and
>>>> maybe the bridge has been improved in the meantime :)
>>>>
>>> I checked out the 2.6.29-rc8 vanilla kernel.
>>> The performance after issuing lxc-start improved to 8.7 Gbps!
>>> It's a big improvement, while some performance loss remains.
>>> Can not we avoid this loss?
>> Good question.  Any chance you can profile this and see where the
>> performance loss seems to be coming from?
>>
> I found out this issue is caused by decreasing the MTU size.
> Myri-10G's MTU size is 9000 bytes; the veth' MTU size is 1500 bytes.
> After bridging veth, MTU size decreases from 9000 to 1500 bytes.
> I changed the veth's MTU size to 9000 bytes, and then I confirmed
> the throughput improved to 9.6 Gbps.
> 
> The throughput between LXC containers also improved to 4.9 Gbps
> by changing the MTU sizes.
> 
> So I propose to add lxc.network.mtu into the LXC configuration.
> How does that sound?

Sounds good :)
Do you plan to send a patch ?

From: "juice" <juice@swagman.org>
Subject: Re: Hight speed data sending from custom IP out of kernel
Date: Tue, 19 Apr 2011 19:02:02 +0300
Message-ID: <45cb2254ff23a4977c95b0f9459e39a6.squirrel@www.liukuma.net>
References: <53f539ea861e1a24bde4aadceff0b3bb.squirrel@www.liukuma.net>
    <4DAD76F1.40309@monstr.eu>
Reply-To: juice@swagman.org
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: monstr@monstr.eu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.liukuma.net ([62.220.235.15]:34595 "EHLO www.liukuma.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752996Ab1DSQCO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 12:02:14 -0400
In-Reply-To: <4DAD76F1.40309@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi!

I can see you are probably going to run into CPU performance problems, but
it depends a lot on the type of traffic you are going to send.

My system requires quite fast processor, but even more important is to
have a network interface card that really supports the full speed of
gigabit ethernet line. The reason for that is that my test traffic
includes streams of very small packets that cause a lot of overhead in
processing.

Most of my test traffic is UDP, but it does not really matter what the
higher layers of the traffic are, this scheme operates on the ethernet
layer and does not care about payload structure.

I tried several NIC:s before i settled using Intel 82576 cards with the
igb driver. If you have less capable interface card, your small packet
performance is going to be a lot poorer.

Using that card I can get to full speed GE line rate even with 64byte
packets, but if you want to send larger packets, say close to 1500byte
then almost any NIC will work OK for you.

You can download the module code and the userland seeding application from
my svn server at https://toosa.swagman.org/svn/streamgen
The streamseed userland application requires libpcap-dev to build
correctly but the streamgen module is self-sufficent.

There is not a lot of documentation, and the module is still "work in
progress" as I am going to fix it to work with more than one interface at
the same time when I get to do it. Currently it can only use one interface
on the sending host machine.

  - Juice -


> Hi Juice,
>
> juice wrote:
>> Hi Michal.
>>
>> How fast do you need to send the data?
>
> It sounds weird but as fast as possible. There is no specific limit
> because I
> want to create demo and test it on various hw configuration which I can
> easily
> create on FPGA. For now the bottleneck is Microblaze cpu. It can run from
> 50MHz
> till 170-180MHz. We also support both endians and have two hw IP
> cores(10/100/1000) which I can use.
>
>> I have an application where I send test stream out to GE line and can
>> fill
>> the total capacity of the ethernet regardless of the packet size.
>
> What cpu do you use?
>
>>
>> The test stream I am sending is stored in kernel memory, and therefore
>> is
>> limited by the amount of free memory. 200M is no problem.
>
> Is it UDP or TCP?
>
>>
>> The solution I am using is loosely based on the pktgen module, except
>> that
>> my module can load a wireshark capture from userland program and then
>> send
>> it from ethernet interface in wire speed.
>
> Sound good. Would it be possible to see it and test it?
>
> Thanks,
> Michal
>
>
>>
>>   - Juice -
>>
>>
>>> Hi,
>>> I would like to create demo for high speed data sending from custom IP
>> through
>>> the ethernet. I think the best description is that there are dmaable
>>> memory
>>> mapped registers or just memory which store data I want to send (for
>> example 200MB).
>>> Linux should handle all communication between target(probably server)
>> and
>>> host
>>> (client) but data in the packets should go from that custom IP and
>>> can't go
>>> through the kernel because of performance issue.
>>> Ethernet core have own DMA which I could use but the question is if
>> there
>>> is any
>>> option how to convince the kernel that data will go directly from
>>> memory
>> mapped
>>> registers and the kernel/driver/... just setup dma BD for headers and
>> second for
>>> data.
>>> Do you have any experience with any solution with passing data
>> completely
>>> out of
>>> kernel?
>>> Thanks,
>>> Michal
>>> --
>>> Michal Simek, Ing. (M.Eng)
>>> w: www.monstr.eu p: +42-0-721842854
>>> Maintainer of Linux kernel 2.6 Microblaze Linux -
>>> http://www.monstr.eu/fdt/
>>> Microblaze U-BOOT custodian
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the
>> body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>>
>>
>
>
> --
> Michal Simek, Ing. (M.Eng)
> w: www.monstr.eu p: +42-0-721842854
> Maintainer of Linux kernel 2.6 Microblaze Linux -
> http://www.monstr.eu/fdt/
> Microblaze U-BOOT custodian
>



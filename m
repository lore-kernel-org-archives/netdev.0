From: Sharat Masetty <sharat04@gmail.com>
Subject: Re: Packet drops observed @ LINUX_MIB_TCPBACKLOGDROP
Date: Thu, 27 Feb 2014 13:40:53 -0700
Message-ID: <CAJzFV35yDOpCx=yPrrN3o4QLFdJLq9E2Jo+v2HsyyVP1q30aUg@mail.gmail.com>
References: <CAJzFV35=wUOA+pQCkAwV2+oF79VAmbsRY08gZUiFz-Vtw-898w@mail.gmail.com>
	<1393523649.26794.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, harout@hedeshian.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:42445 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384AbaB0Uky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 15:40:54 -0500
Received: by mail-wi0-f176.google.com with SMTP id hi5so7755982wib.9
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 12:40:53 -0800 (PST)
In-Reply-To: <1393523649.26794.22.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

We are using kernel version 3.10.0 and network driver is our own
driver designed to work on hsic-usb interconnect. One thing is for
sure is that we do not pre allocate lots buffers to hold incoming
traffic, we only allocate buffers of required size when there is data
to read off the bus.

I was under the impression that this backlog queue is charged against
the socket buffer space(sndbuf and rcvbuf), so I am trying to
understand in more detail how the driver implementation can be linked
to this drops in the backlog queue.

Can you explain to me the significance of this backlog queue? mainly
from the perspective of the userspace application(in this case iperf)
socket API calls and the kernel/network stack enqueuing packets up the
stack..

Thanks
Sharat


On Thu, Feb 27, 2014 at 10:54 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2014-02-26 at 19:00 -0700, Sharat Masetty wrote:
>> Hi,
>>
>> We are trying to achieve category 4 data rates on an ARM device. We
>> see that with an incoming TCP stream(IP packets coming in and acks
>> going out) lots of packets are getting dropped when the backlog queue
>> is full. This is impacting overall data TCP throughput. I am trying to
>> understand the full context of why this queue is getting full so
>> often.
>>
>> From my brief look at the code, it looks to me like the user space
>> process is slow and busy in pulling the data from the socket buffer,
>> therefore the TCP stack is using this backlog queue in the mean time.
>> This queue is also charged against the main socket buffer allocation.
>>
>> Can you please explain this backlog queue, and possibly confirm if my
>> understanding this  matter is accurate?
>> Also can you suggest any ideas on how to mitigate these drops?
>
> You forgot to tell us things like :
>
> 1) Kernel version
> 2) Network driver in use.
>
> Some drivers allocate huge buffers to store incoming frames.
>
> Unfortunately we have to avoid OOM issues in the kernel, so such drivers
> are likely to have some skb dropped by the backlog.
>
>
>

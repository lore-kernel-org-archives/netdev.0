From: Prashant Upadhyaya <praupadhyaya@gmail.com>
Subject: Re: Load Balancing for AF_INET Raw Sockets
Date: Thu, 17 Dec 2015 11:40:21 +0530
Message-ID: <CAPBAu3XWzO5GT1cceVgYCJ2Du_p+yht3moBPuKrn-i_O5yLJvw@mail.gmail.com>
References: <CAPBAu3Uz5P-uJ3Hqg=K49PLDkaGtUWW_SGAH0mTvAsevwvE7Ew@mail.gmail.com>
	<1450190376.8474.28.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:33409 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932239AbbLQGKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 01:10:22 -0500
Received: by mail-ig0-f177.google.com with SMTP id mv3so6896824igc.0
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 22:10:21 -0800 (PST)
In-Reply-To: <1450190376.8474.28.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 15, 2015 at 8:09 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2015-12-15 at 18:26 +0530, Prashant Upadhyaya wrote:
>> Hi,
>>
>> I open a raw socket for listening to all the UDP packets in a raw fashion --
>>
>> socket(AF_INET, SOCK_RAW, IPPROTO_UDP);
>>
>> Then I use recvfrom to read the packets over the socket.
>>
>> The above works mighty fine.
>> I want to find out if it is possible to 'load balance' the UDP flows
>> by opening up multiple instances of this socket and then possibly
>> setting some socket options so that I can scale up the reading via
>> multiple threads doing recvfrom on these from multiple cores.
>> (I know it is possible over packet sockets, but that is a different usecase)
>
> No plan yet to support fanout on multiple raw sockets.
>
>
Hi,

One question on the AF_INET6 raw sockets.
Here I don't get the ipv6 header at all when I read a packet.
I checked the RFC 3542 and it specifies the following as the ancillary
data which can be obtained --

Four similar pieces of information can be returned for a received
   packet as ancillary data:

      1.  the destination IPv6 address,
      2.  the arriving interface index,
      3.  the arriving hop limit, and
      4.  the arriving traffic class value.

Now how do I obtain the 'src IPv6 address' ?

Regards
-Prashant

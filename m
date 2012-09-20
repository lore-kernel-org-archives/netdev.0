From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Thu, 20 Sep 2012 14:39:08 -0700
Message-ID: <CAGK4HS8T=aoz0YdsJg5m0OofXWVGL4Re3fc-DVyfw3egJcgDxQ@mail.gmail.com>
References: <20120917.121243.1665284878800146060.davem@davemloft.net>
	<1347901326.26523.149.camel@edumazet-glaptop>
	<1347901493.26523.151.camel@edumazet-glaptop>
	<20120917.130732.1894375657044880827.davem@davemloft.net>
	<1348067659.26523.949.camel@edumazet-glaptop>
	<CAGK4HS_ZKKrzFh+c3WDxbkMFpDTg7ehw9ydp39k6JPFA_j1YOw@mail.gmail.com>
	<1348119475.31352.60.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:62337 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753027Ab2ITVjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 17:39:09 -0400
Received: by obbuo13 with SMTP id uo13so1973161obb.19
        for <netdev@vger.kernel.org>; Thu, 20 Sep 2012 14:39:09 -0700 (PDT)
In-Reply-To: <1348119475.31352.60.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>> I applied this patch to net-next and tested with e1000e driver.
>> With iperf I got around 8 % improvement on loopback.
>>
>> Tested-by: Vijay Subramanian <subramanian.vijay@gmail.com>

I think this tag should be on the thread with the actual patch. I will
reply to your patch with the Tested-by tag.

Thanks for your tips, Eric. For what its worth, here is what I found.

>
> If you keep the producer and consumer on separate cpus, and use large
> enough send() (64KB or 128KB), gain is more like 15 or 20%
>

Curiously, when I use taskset to run iperf server and client on
different cpus, throughput goes down by half
for both baseline (master branch) and with patch. Is taskset the right
way to test this?

I did notice a change in absolute throughout when I increase the
send() buffer size.
However, both the basline as well the patch showed improvement but the
relative improvement
was still around 8%.


> iperf uses 8KB writes, while netperf uses a 16KB default.

I think iperf has a bug. Both man page and comments in code claim
default buffer size for read/write is 8KB but
actual number seems to be 128KB. I believe the actual default is 128KB
not 8KB (-l option with iperf).


Thanks !
Vijay

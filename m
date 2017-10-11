From: "Sergey K." <simkergey@gmail.com>
Subject: Re: High CPU load by native_queued_spin_lock_slowpath
Date: Wed, 11 Oct 2017 11:46:09 +0600
Message-ID: <CAGv8E+xwzwZgEsGb6wmG3KFffMRxGKmGBqrueHwXzFwv2WB=_Q@mail.gmail.com>
References: <CAGv8E+xZOweXEedymRuLt4idQmCM8Mk1TZOM=0p3YmnXbh-n+g@mail.gmail.com>
 <1507644432.31614.13.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:54763 "EHLO
        mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751499AbdJKFqK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 01:46:10 -0400
Received: by mail-io0-f182.google.com with SMTP id h66so934777ioh.11
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 22:46:10 -0700 (PDT)
In-Reply-To: <1507644432.31614.13.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm using ifb0 device for outgoing traffic.
I have one bond0 interface with exit to the Internet, and 2 interfaces
eth0 and eth2 to local users.
ifb0 - for shaping Internet traffic from bond0 to eth2 or eth0.
All outgoing traffic to the eth0 and eth2 redirecting to ifb0.

> What about multiple ifb instead, one per RX queue ?
You are offering to redirect traffic from every queue to personal ifb
device? I do not quite understand.

2017-10-10 20:07 GMT+06:00 Eric Dumazet <eric.dumazet@gmail.com>:
> On Tue, 2017-10-10 at 18:00 +0600, Sergey K. wrote:
>> I'm using Debian 9(stretch edition) kernel 4.9., hp dl385 g7 server
>> with 32 cpu cores. NIC queues are tied to processor cores. Server is
>> shaping traffic (iproute2 and htb discipline + skbinfo + ipset + ifb)
>> and filtering some rules by iptables.
>>
>> At that moment, when traffic goes up about 1gbit/s cpu is very high
>> loaded. Perf tool tells me that kernel module
>> native_queued_spin_lock_slowpath loading cpu about 40%.
>>
>> After several hours of searching, I found that if I remove the htb
>> discipline from ifb0, the high load goes down.
>> Well, I think that problem with classify and shaping by htb.
>>
>> Who knows how to solve?
>
> You use a single ifb0 on the whole (multiqueue) device for ingress ?
>
> What about multiple ifb instead, one per RX queue ?
>
> Alternative is to reduce contention and use a single RX queue.
>
>

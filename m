From: Chetan Loke <chetanloke@gmail.com>
Subject: Re: [Pv-drivers] rps and pvdrivers
Date: Sat, 4 Sep 2010 09:38:30 -0400
Message-ID: <AANLkTimC4z7mCKwyK8=LaacjTtZGEGN_BYsFMydQiwBk@mail.gmail.com>
References: <AANLkTimrHh1ZasO=GWUOT9YJbu2EqeAx6OkRXPUSSNJ6@mail.gmail.com>
	<8B1F619C9F5F454E81D90D3C161698D70337A49A5A@EXCH-MBX-3.vmware.com>
	<AANLkTi=o8GYdLyY8EzfRno39O2kUSh3wSp9raZCUp_Zz@mail.gmail.com>
	<1283583095.2320.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Bhavesh Davda <bhavesh@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"therbert@google.com" <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52432 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752982Ab0IDNic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 09:38:32 -0400
Received: by fxm13 with SMTP id 13so1790343fxm.19
        for <netdev@vger.kernel.org>; Sat, 04 Sep 2010 06:38:31 -0700 (PDT)
In-Reply-To: <1283583095.2320.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Sat, Sep 4, 2010 at 2:51 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Reproduce what exactly ?
>
> I dont understand what the problem is, reading your description.

With 2.6.35 the rx-path performance on a 10G vNIC is way too low. If
you setup a simple 'recvfrom' loop on a promiscuous interface you can
see this easily.
My use-case is to achieve high speed pkt capturing.


> RPS is not automatically switched on, you have to configure it.
>
> echo ffff >/sys/class/net/eth0/queues/rx-0/rps_cpus
>
> Same for RFS if you prefer to use RFS
>
> echo 16384 >/sys/class/net/eth0/queues/rx-0/rps_flow_cnt
>

Ok, thanks for sharing this. I tried this and still doesn't help.

> If you receive a flood, your cpu stay in NAPI mode, and no hardware
> interrupt is received while you process xxx.xxx packets per second.
>

I see. Ok then that's whats happening. I guess I will have to look at
the napi/ksoftirq/rps block in detail to understand this. But I would
think that even w/o the rps settings I should still get the same
numbers as compared to non-rps case, correct?

On a VM(virtual machine) using a 1G vNIC I can capture ~250K
pkts/sec(even higher in some cases). But I can't go beyond 100K
pkts/sec on a 10G vNIC because ksoftirqd consumes 1-cpu 100% of the
time. That's why I thought of switching to the 2.6.35 kernel to see if
I could scale on 10G.

It's possible that a VM cannot handle that much load. So I tried
sending only 10% of line-rate(10G) which is 1G. It still doesn't work.
I still can't capture that many pkts.


Chetan Loke

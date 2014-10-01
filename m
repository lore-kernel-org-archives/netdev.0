From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next PATCH V5] qdisc: bulk dequeue support for qdiscs with TCQ_F_ONETXQUEUE
Date: Wed, 1 Oct 2014 07:55:21 -0700
Message-ID: <CA+mtBx8rVu9FXtnc18n22L9LP=t=3Pso7U2yvvLcnny57w8aXg@mail.gmail.com>
References: <20140930085114.24043.81310.stgit@dragon>
	<542A8EF9.10403@mojatatu.com>
	<20140930.142038.235338672810639160.davem@davemloft.net>
	<542BFEF3.7020302@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:51017 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbaJAOzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 10:55:22 -0400
Received: by mail-ig0-f180.google.com with SMTP id uq10so480222igb.13
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 07:55:21 -0700 (PDT)
In-Reply-To: <542BFEF3.7020302@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 1, 2014 at 6:17 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 09/30/14 14:20, David Miller wrote:
>>
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>> Date: Tue, 30 Sep 2014 07:07:37 -0400
>>
>>> Note, there are benefits as you have shown - but i would not
>>> consider those to be standard use cases (actully one which would
>>> have shown clear win is the VM thing Rusty was after).
>>
>>
>> I completely disagree, you will see at least decreased cpu utilization
>> for a very common case, bulk single stream transfers.
>>
>
>
> So lets say the common use case is:
> = modern day cpu (pick some random cpu)
> = 1-10 Gbps ethernet (not 100mbps)
> = 1-24 tcp or udp bulk (you said one, Jesper had 24 which sounds better)
>
> Run with test cases:
> a) unchanged (no bulking code added at all)
> vs
> b) bulking code added and used
> vs
> c) bulking code added and *not* used
>
> Jesper's results are comparing #b and #c.
>
> And if #b + #c are slightly worse or equal then we have a win;->
>
> Again, I do believe things like traffic generators or the VM io
> or something like tuntap that crosses user space will have a clear
> benefit (but are those common use cases?).
>
You're making this much more complicated that it actually is. The
algorithm is simple-- queue wakes up, finds out how exactly many bytes
to dequeue, and performs dequeue of enough packets under one lock. The
should be a benefit when transmitting high rate as we know that
reducing locking is generally a win. It needs to be tested, but this
should be independent of whether application is a VM, in userspace or
kernel, packetgen, etc.

Tom

> cheers,
> jamal

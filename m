From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] net: introduce napi_schedule_irqoff()
Date: Wed, 29 Oct 2014 08:26:16 -0700
Message-ID: <CAADnVQLFZopMmFFpu3B-wBT=8vOWG=Oy3PO+pGcykZsfKd3sBg@mail.gmail.com>
References: <1414544713.631.30.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAADnVQJ0XD6YmUi_MBpoEgkScxp2ictQepY2YqtvfbXzF=voZQ@mail.gmail.com>
	<1414553435.631.41.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAADnVQJVizFA_Tpf0FpyH0uoKZa4TMiBaNPmD_-5Z5+Vg+hV8Q@mail.gmail.com>
	<1414557621.631.52.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAADnVQJzk2_Kx=BGpYnNzpQb7OqSZ+KaeKFbUZxJ27WKC+DZww@mail.gmail.com>
	<1414563627.631.75.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:48715 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932962AbaJ2P0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 11:26:34 -0400
Received: by mail-qg0-f42.google.com with SMTP id i50so1508504qgf.29
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 08:26:33 -0700 (PDT)
In-Reply-To: <1414563627.631.75.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 28, 2014 at 11:20 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-10-28 at 22:13 -0700, Alexei Starovoitov wrote:
>
>> tried 50 parallel netperf -t TCP_RR over ixgbe
>> and perf top were tcp stack bits, qdisc locks and netperf itself.
>> What do you see?
>
> You are kidding right ?
>
> If you save 30 nsec ( 2 * 15 nsec) per transaction, and rtt is about 20
> usec, its a 0.15 % gain. Not bad for a trivial patch.

agreed.
I wasn't arguing against the patch at all. Was just curious
what performance gain we'll see. 0.15% is tiny and some might
say the code bloat is not worth it, but imo it's a good one. ack.

> Every atomic op we remove/avoid, every irq masking unmasking we remove,
> every cache line miss or extra bus transaction we remove, TLB miss, is
> the path for better latency.

yes. We're saying the same thing.

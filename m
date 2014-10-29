From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: introduce napi_schedule_irqoff()
Date: Tue, 28 Oct 2014 23:20:27 -0700
Message-ID: <1414563627.631.75.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414544713.631.30.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAADnVQJ0XD6YmUi_MBpoEgkScxp2ictQepY2YqtvfbXzF=voZQ@mail.gmail.com>
	 <1414553435.631.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAADnVQJVizFA_Tpf0FpyH0uoKZa4TMiBaNPmD_-5Z5+Vg+hV8Q@mail.gmail.com>
	 <1414557621.631.52.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAADnVQJzk2_Kx=BGpYnNzpQb7OqSZ+KaeKFbUZxJ27WKC+DZww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:55996 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753578AbaJ2GU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 02:20:28 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so2472029pab.36
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2014 23:20:27 -0700 (PDT)
In-Reply-To: <CAADnVQJzk2_Kx=BGpYnNzpQb7OqSZ+KaeKFbUZxJ27WKC+DZww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-10-28 at 22:13 -0700, Alexei Starovoitov wrote:

> tried 50 parallel netperf -t TCP_RR over ixgbe
> and perf top were tcp stack bits, qdisc locks and netperf itself.
> What do you see?

You are kidding right ?

If you save 30 nsec ( 2 * 15 nsec) per transaction, and rtt is about 20
usec, its a 0.15 % gain. Not bad for a trivial patch.

Why are you using 50 parallel netperf, instead of trying a single
netperf, as I mentioned latency impact, not overall throughput ?

Do you believe typical servers in data centers are only sending &
receiving bulk packets, with no interrupt, and one cpu busy polling in
NAPI handler ?


Every atomic op we remove/avoid, every irq masking unmasking we remove,
every cache line miss or extra bus transaction we remove, TLB miss, is
the path for better latency.

You should take a look at recent commits I did, you'll get the general
picture if you missed it.

git log --oneline --author dumazet | head -100

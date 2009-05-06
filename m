From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: bond + tc regression ?
Date: Wed, 6 May 2009 06:10:10 +0000
Message-ID: <20090506061010.GA4571@ff.dom.local>
References: <20090505174135.GA29716@francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Vladimir Ivashchenko <hazard@francoudi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f224.google.com ([209.85.219.224]:62452 "EHLO
	mail-ew0-f224.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbZEFGKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 02:10:15 -0400
Received: by ewy24 with SMTP id 24so5650608ewy.37
        for <netdev@vger.kernel.org>; Tue, 05 May 2009 23:10:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090505174135.GA29716@francoudi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05-05-2009 19:41, Vladimir Ivashchenko wrote:
>>> On both kernels, the system is running with at least 70% idle CPU.
>>> The network interrupts are distributed accross the cores.
>> You should not distribute interrupts, but bound a NIC to one CPU
> 
> Kernels 2.6.28 and 2.6.29 do this by default, so I thought its correct.
> The defaults are wrong?
> 
...
>> ifconfig -a
> 
> bond0     Link encap:Ethernet  HWaddr 00:1B:24:BD:E9:CC
>           inet addr:xxx.xxx.135.44  Bcast:xxx.xxx.135.47  Mask:255.255.255.248
>           inet6 addr: fe80::21b:24ff:febd:e9cc/64 Scope:Link
>           UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
>           RX packets:436076190 errors:0 dropped:391250 overruns:0 frame:0
>           TX packets:2620156321 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0
>           RX bytes:4210046233 (3.9 GiB)  TX bytes:2520272242 (2.3 GiB)

Could you try e.g.: ifconfig bond0 txqueuelen 1000
before tc qdisc add?

Jarek P.

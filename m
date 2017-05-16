From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: switchdev offload & ecmp
Date: Tue, 16 May 2017 14:57:47 +0200
Message-ID: <4c70d1fc-ba11-e358-2142-d373f44cb5a1@6wind.com>
References: <84b9801f-0c2a-cd55-61a4-411261943024@6wind.com>
 <20170515164036.GA5669@splinter.mtl.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: Jiri Pirko <jiri@resnulli.us>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        netdev <netdev@vger.kernel.org>
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:34534 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751990AbdEPM5v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 08:57:51 -0400
Received: by mail-wm0-f51.google.com with SMTP id u65so35816527wmu.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 05:57:50 -0700 (PDT)
In-Reply-To: <20170515164036.GA5669@splinter.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/05/2017 à 18:40, Ido Schimmel a écrit :
[snip]
>> Is there a consistency between the ecmp algorithm of the kernel and the one from
>> spectrum?
> 
> We currently use the hardware's defaults for ECMP hashing, which include
> both L3 and L4 fields. I'm aware of Nik's patch, but we've yet to
> reflect that. Note that the L4 fields aren't considered for fragmented
> packets.
Ok.

> 
>> I suspect that there can be scenarii where some packets of a flow are forwarded
>> by the driver and some other are forwarded by the kernel.
> 
> Can you elaborate? The kernel only sees specific packets, which were
> trapped to the CPU. See:
> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/tree/drivers/net/ethernet/mellanox/mlxsw/spectrum.c#n2996
Ok, this part was not clear for me, thank you for the pointer.

So, when an arp resolution is needed, the packets are not trapped to the CPU,
the device manages the queue itself?

> 
>> For example, an ecmp route with two nexthops: a connected route and a gw? 
> 
> Not sure I'm following you. A packet will either hit a remote route or a
> directly connected one. We distinguish between the two based on the
> scope of the first nexthop in the group. See:
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c#n2043
> 
>> In that case, the periodic nexthops update
>> (https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c#n987)
>> won't help. How do you ensure that all packets of the flow are always forwarded
>> through the same nexthop?
> 
> I don't think we can ensure that for a flow in which some packets are
> forwarded by the kernel and some by the device, but I failed to
> understand your example of such a flow.
I was trying to understand if nexthop choice is always the same in the kernel
and in the device. And I was also trying to understand if it's possible to have
some packets of a flow routed by the kernel and some others by the device.


Thank you for the answers,
Nicolas

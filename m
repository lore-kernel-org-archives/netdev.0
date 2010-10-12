From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next] bnx2x: dont use netdev_alloc_skb()
Date: Mon, 11 Oct 2010 22:03:43 -0700
Message-ID: <AANLkTi=NvnPov_=KQJz2uXt1R-ep4oahDF0J=3HwhGzG@mail.gmail.com>
References: <1286838210.30423.128.camel@edumazet-laptop>
	<1286839363.30423.130.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:2699 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892Ab0JLFE2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 01:04:28 -0400
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o9C54QDl028779
	for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 22:04:26 -0700
Received: from pvh11 (pvh11.prod.google.com [10.241.210.203])
	by kpbe20.cbf.corp.google.com with ESMTP id o9C53jfU008875
	for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 22:03:45 -0700
Received: by pvh11 with SMTP id 11so48985pvh.35
        for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 22:03:45 -0700 (PDT)
In-Reply-To: <1286839363.30423.130.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 11, 2010 at 4:22 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 12 octobre 2010 =E0 01:03 +0200, Eric Dumazet a =E9crit :
>> netdev_alloc_skb() is a very wrong interface, really.
>>
>> We should remove/deprecate it.
>>
>> For multi queue devices, it makes more sense to allocate skb on loca=
l
>> node of the cpu handling RX interrupts. This allow each cpu to
>> manipulate its own slub/slab queues/structures without doing expensi=
ve
>> cross-node business.
>>
>> For non multi queue devices, IRQ affinity should be set so that a cp=
u
>> close to the device services interrupts. Even if not set, using
>> dev_alloc_skb() is faster.
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>
> Or maybe revert :
>
> commit b30973f877fea1a3fb84e05599890fcc082a88e5
> Author: Christoph Hellwig <hch@lst.de>
> Date: =A0 Wed Dec 6 20:32:36 2006 -0800
>

I second this revert.  Node aware allocation by device's node makes
little sense on a multi-queue device and leads to mediocre
performance.

> =A0 =A0[PATCH] node-aware skb allocation
>
> =A0 =A0Node-aware allocation of skbs for the receive path.
>
> =A0 =A0Details:
>
> =A0 =A0 =A0- __alloc_skb gets a new node argument and cals the node-a=
ware
> =A0 =A0 =A0 =A0slab functions with it.
> =A0 =A0 =A0- netdev_alloc_skb passed the node number it gets from dev=
_to_node
> =A0 =A0 =A0 =A0to it, everyone else passes -1 (any node)
>
> =A0 =A0Signed-off-by: Christoph Hellwig <hch@lst.de>
> =A0 =A0Cc: Christoph Lameter <clameter@engr.sgi.com>
> =A0 =A0Cc: "David S. Miller" <davem@davemloft.net>
> =A0 =A0Signed-off-by: Andrew Morton <akpm@osdl.org>
>
>
> Apparently, only Christoph and Andrew signed it.
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>

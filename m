From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: RE: gianfar select_queue bogosity (was Re: ixgbe warning)
Date: Thu, 24 Dec 2009 12:04:57 +0530
Message-ID: <OF474C8482.CADDE68E-ON65257696.00225320-65257696.00231F54@in.ibm.com>
References: <86802c440912222100j1c23f3d9xfb734a6e52fa2ec9@mail.gmail.com><OF748A4720.94B5A869-ON65257695.00267BA3-65257695.0027EDC4@in.ibm.com> <20091223.211157.68124463.davem@davemloft.net> <9F4C7D19E8361D4C94921B95BE08B81BA0904E@zin33exm22.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: avorontsov@ru.mvista.com, "David Miller" <davem@davemloft.net>,
	e1000-devel@lists.sourceforge.net, galak@kernel.crashing.org,
	netdev@vger.kernel.org, yinghai@kernel.org
To: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([122.248.162.2]:54375 "EHLO
	e28smtp02.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751834AbZLXGXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2009 01:23:49 -0500
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp02.in.ibm.com (8.14.3/8.13.1) with ESMTP id nBO6NhWM000581
	for <netdev@vger.kernel.org>; Thu, 24 Dec 2009 11:53:43 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBO6Nhb32601204
	for <netdev@vger.kernel.org>; Thu, 24 Dec 2009 11:53:43 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBO6Ng5p006793
	for <netdev@vger.kernel.org>; Thu, 24 Dec 2009 17:23:43 +1100
In-Reply-To: <9F4C7D19E8361D4C94921B95BE08B81BA0904E@zin33exm22.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Kumar Gopalpet-B05799" <B05799@freescale.com> wrote on 12/24/2009 11:34:23
AM:

>
> >From: Krishna Kumar2 <krkumar2@in.ibm.com>
> >Date: Wed, 23 Dec 2009 12:57:26 +0530
> >
> >> Also, I was looking at other providers of select_queue and found:
> >>
> >> u16 gfar_select_queue(struct net_device *dev, struct sk_buff *skb) {
> >>         return skb_get_queue_mapping(skb); }
> >>
> >> How can this be correct (driver supports upto 8 txq's). Unless txq=0
> >> for xmits of all locally generated packets is fine.
> >
> >This must be fixed.  As you note the queue mapping is only set
> >for forwarding/bridging cases.
> >
>
> Yes, the queue_mapping is set for forwarding/bridginh applications.
>
> >There is zero reason for this driver to have it's own
> >select_queue function, so the fix seems to simply remove this
> >thing altogether.
> >
> What if I want to maintaing a 1-1 mapping b/w the Rx/Tx queues.
> For eg., I want a packet received on queue-1 on eth0 to be forwarded on
> to queue-1 on eth1.
>
> Is there some way where we can handle both kinds of applications i.e.,
> forwarding/bridging and
> locally  generated packets.
>
> >Some gianfar developer please prepare such a patch, thanks.
>
> If you want gfar_select_queue( ) function to be removed for now, I will
> do that.
> But, I would also want to maintain the above explained scenario to be
> handled for forwarding/bridging applications.
>
> Please provide your inputs

Your requirement will be met if you remove select_queue handler.
dev_pick_tx() calls skb_tx_hash() and since rx is recorded, it
uses txq#=rxq# automatically. This also handles both locally
generated packets and forwarding/bridging - locally generated
packets will execute the optimized path (sk_tx_queue_recorded)
after the first time txq is selected.

Thanks,

- KK


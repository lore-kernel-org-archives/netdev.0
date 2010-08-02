From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] Multiqueue macvtap driver
Date: Mon, 2 Aug 2010 18:07:40 +0530
Message-ID: <OF8519C301.F0E5FA07-ON65257772.004983CC-65257773.00453C8B@in.ibm.com>
References: <20100731135743.3072.99933.sendpatchset@krkumar2.in.ibm.com>	<1280603907.13192.353.camel@localhost> <20100801.003406.02275545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: arnd@arndb.de, bhutchings@solarflare.com, mst@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([122.248.162.6]:49382 "EHLO
	e28smtp06.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152Ab0HBMgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 08:36:20 -0400
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp06.in.ibm.com (8.14.4/8.13.1) with ESMTP id o72CaIBl030774
	for <netdev@vger.kernel.org>; Mon, 2 Aug 2010 18:06:18 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o72CaHTV1695880
	for <netdev@vger.kernel.org>; Mon, 2 Aug 2010 18:06:18 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o72CaHFD029031
	for <netdev@vger.kernel.org>; Mon, 2 Aug 2010 22:36:17 +1000
In-Reply-To: <20100801.003406.02275545.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Ben & Dave. A question though - which of the following
is preferable for the macvtap driver:

1. Calculate flow and use that to find a queue; or
2. First check if skb_rx_queue_recorded is true and if so use
    that; otherwise calculate the flow as in #1.

I guess #1 is better, since packets for a single flow will go to the
same queue even if they arrive on different rxqs of a mq driver.
But I want to make sure.

Thanks,

- KK

David Miller <davem@davemloft.net> wrote on 08/01/2010 01:04:06 PM:

> David Miller <davem@davemloft.net>
> 08/01/2010 01:04 PM
>
> To
>
> bhutchings@solarflare.com
>
> cc
>
> Krishna Kumar2/India/IBM@IBMIN, arnd@arndb.de,
> netdev@vger.kernel.org, mst@redhat.com
>
> Subject
>
> Re: [PATCH] Multiqueue macvtap driver
>
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Sat, 31 Jul 2010 20:18:27 +0100
>
> > On Sat, 2010-07-31 at 19:27 +0530, Krishna Kumar wrote:
> > [...]
> >> @@ -136,39 +158,68 @@ static void macvtap_put_queue(struct mac
> >>  }
> >>
> >>  /*
> >> - * Since we only support one queue, just dereference the pointer.
> >> + * Select a queue based on the rxq of the device on which this packet
> >> + * arrived. If the incoming device is not mq, then use our cpu number
> >> + * to select a queue. vlan->numvtaps is cached in case it changes
> >> + * during the execution of this function.
> >>   */
> > [...]
> >
> > This can result in reordering if a single-queue device's RX interrupt's
> > CPU affinity is changed.  We generally try to avoid that.  You should
> > really use or generate a flow hash.  There is code for this in
> > net/core/dev.c:get_rps_cpu() which could be factored out into a
separate
> > function.
>
> Agreed.


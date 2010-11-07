From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 2/2 v5] xps: Transmit Packet Steering
Date: Sun, 7 Nov 2010 15:11:51 -0800
Message-ID: <AANLkTiketXseg+zZW90Aqod+4ej7bHqyRAjH76kN654h@mail.gmail.com>
References: <alpine.DEB.1.00.1011071146390.29978@pokey.mtv.corp.google.com>
	<1289162455.2478.295.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:38331 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753572Ab0KGXLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 18:11:54 -0500
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id oA7NBr2W011148
	for <netdev@vger.kernel.org>; Sun, 7 Nov 2010 15:11:53 -0800
Received: from pzk30 (pzk30.prod.google.com [10.243.19.158])
	by hpaq13.eem.corp.google.com with ESMTP id oA7NBpTA011613
	for <netdev@vger.kernel.org>; Sun, 7 Nov 2010 15:11:52 -0800
Received: by pzk30 with SMTP id 30so1004170pzk.18
        for <netdev@vger.kernel.org>; Sun, 07 Nov 2010 15:11:51 -0800 (PST)
In-Reply-To: <1289162455.2478.295.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Tom, I still dont understand why *xps_maps is here, and not in
> net_device ?
>

Originally it was in the net_device, but that necessitated a reference
be held on the device since we can't destroy the map until all
kobjects were released, but the open reference prevents the kojects
from being released in the first place.

> I am asking because netdev_get_xps_maps(dev) might be slowed down
> because queue 0 state might change often (__QUEUE_STATE_XOFF)
>
Could a add a pointer in the net_device also.

> This means _tx[0] becomes a very hot cache line, needed to access all
> queues (from get_xps_queue())
>
> Other than that, your patch seems fine (not tested yet)
>
> Thanks
>
>
>

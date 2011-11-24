From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] macvtap: Fix macvtap_get_queue to use rxhash first
Date: Thu, 24 Nov 2011 16:44:34 +0530
Message-ID: <OF12661931.5C4899F8-ON65257952.003B84A6-65257952.003D8DA6@in.ibm.com>
References: <20111124081714.26635.68141.sendpatchset@krkumar2.in.ibm.com> <20111124095902.GD14491@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: arnd@arndb.de, davem@davemloft.net, jasowang@redhat.com,
	levinsasha928@gmail.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	jeffrey.t.kirsher@intel.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([122.248.162.3]:40222 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938Ab1KXLpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 06:45:25 -0500
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <krkumar2@in.ibm.com>;
	Thu, 24 Nov 2011 16:52:04 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAOBGsUK4726796
	for <netdev@vger.kernel.org>; Thu, 24 Nov 2011 16:48:39 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAOBCKZc017865
	for <netdev@vger.kernel.org>; Thu, 24 Nov 2011 22:12:21 +1100
In-Reply-To: <20111124095902.GD14491@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael S. Tsirkin" <mst@redhat.com> wrote on 11/24/2011 03:29:03 PM:

> Subject Re: [PATCH] macvtap: Fix macvtap_get_queue to use rxhash first
>
> On Thu, Nov 24, 2011 at 01:47:14PM +0530, Krishna Kumar wrote:
> > It was reported that the macvtap device selects a
> > different vhost (when used with multiqueue feature)
> > for incoming packets of a single connection. Use
> > packet hash first. Patch tested on MQ virtio_net.
>
> So this is sure to address the problem, why exactly does this happen?
> Does your device spread a single flow across multiple RX queues? Would
> not that cause trouble in the TCP layer?
> It would seem that using the recorded queue should be faster with
> less cache misses. Before we give up on that, I'd
> like to understand why it's wrong. Do you know?

I am using ixgbe. From what I briefly saw, ixgbe_alloc_rx_buffers
calls skb_record_rx_queue when a skb is allocated. When a packet
is received (ixgbe_alloc_rx_buffers), it sets rxhash. The
recorded value is different for most skbs when I ran a single
stream TCP stream test (does skbs move between the rx_rings?).
With this patch, macvtap selects the same device for each
incoming packet. I can add some debugs in ixgbe to see what is
happening also. I am not sure if Sasha was using a different
device.

Cc'ing Jeffrey in case he can add something.

thanks,

- KK

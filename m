From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] macvtap: Fix macvtap_get_queue to use rxhash first
Date: Fri, 25 Nov 2011 08:28:16 +0530
Message-ID: <OF2886C7FB.135CFC23-ON65257953.000F9C8A-65257953.00101CBF@in.ibm.com>
References: <20111124081714.26635.68141.sendpatchset@krkumar2.in.ibm.com> <20111124095902.GD14491@redhat.com> <OF12661931.5C4899F8-ON65257952.003B84A6-65257952.003D8DA6@in.ibm.com> <4ECE4004.8010107@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: arnd@arndb.de, davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	levinsasha928@gmail.com, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: jasowang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([122.248.162.3]:52133 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486Ab1KYC4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 21:56:09 -0500
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <krkumar2@in.ibm.com>;
	Fri, 25 Nov 2011 08:26:06 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAP2u1GQ4599872
	for <netdev@vger.kernel.org>; Fri, 25 Nov 2011 08:26:01 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAP2u0Yd011580
	for <netdev@vger.kernel.org>; Fri, 25 Nov 2011 13:56:01 +1100
In-Reply-To: <4ECE4004.8010107@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jasowang <jasowang@redhat.com> wrote on 11/24/2011 06:30:52 PM:

>
> >> On Thu, Nov 24, 2011 at 01:47:14PM +0530, Krishna Kumar wrote:
> >>> It was reported that the macvtap device selects a
> >>> different vhost (when used with multiqueue feature)
> >>> for incoming packets of a single connection. Use
> >>> packet hash first. Patch tested on MQ virtio_net.
> >> So this is sure to address the problem, why exactly does this happen?
> >> Does your device spread a single flow across multiple RX queues? Would
> >> not that cause trouble in the TCP layer?
> >> It would seem that using the recorded queue should be faster with
> >> less cache misses. Before we give up on that, I'd
> >> like to understand why it's wrong. Do you know?
> > I am using ixgbe. From what I briefly saw, ixgbe_alloc_rx_buffers
> > calls skb_record_rx_queue when a skb is allocated. When a packet
> > is received (ixgbe_alloc_rx_buffers), it sets rxhash. The
> > recorded value is different for most skbs when I ran a single
> > stream TCP stream test (does skbs move between the rx_rings?).
>
> Yes, it moves. It depends on last processor or tx queue who transmits
> the packets of this stream. Because ixgbe select tx queue based on the
> processor id, so if vhost thread transmits skbs on different processors,
> the skb of a single stream may comes from different rx ring.

But I don't see transmit going on different queues,
only incoming.

- KK

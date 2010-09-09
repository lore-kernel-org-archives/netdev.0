From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH 1/4] Add a new API to virtio-pci
Date: Thu, 9 Sep 2010 19:19:33 +0530
Message-ID: <OF371A1B54.B0F5B4A1-ON65257799.00491939-65257799.004BBB65@in.ibm.com>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com> <201009091319.40274.rusty@rustcorp.com.au> <OFB29E6C59.96686002-ON65257799.00174D50-65257799.001D6F7B@in.ibm.com> <201009092144.26484.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, davem@davemloft.net, kvm@vger.kernel.org,
	mst@redhat.com, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([122.248.162.2]:59005 "EHLO
	e28smtp02.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169Ab0IINrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 09:47:16 -0400
In-Reply-To: <201009092144.26484.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell <rusty@rustcorp.com.au> wrote on 09/09/2010 05:44:25 PM:
>
> > > This seems a bit weird.  I mean, the driver used vdev->config->
find_vqs
> > > to find the queues, which returns them (in order).  So, can't you put
> > this
> > > into your struct send_queue?
> >
> > I am saving the vqs in the send_queue, but the cb needs
> > to locate the device txq from the svq. The only other way
> > I could think of is to iterate through the send_queue's
> > and compare svq against sq[i]->svq, but cb's happen quite
> > a bit. Is there a better way?
>
> Ah, good point.  Move the queue index into the struct virtqueue?

Is it OK to move the queue_index from virtio_pci_vq_info
to virtqueue? I didn't want to change any data structures
in virtio for this patch, but I can do it either way.

> > > Also, why define VIRTIO_MAX_TXQS?  If the driver can't handle all of
> > them,
> > > it should simply not use them...
> >
> > The main reason was vhost :) Since vhost_net_release
> > should not fail (__fput can't handle f_op->release()
> > failure), I needed a maximum number of socks to
> > clean up:
>
> Ah, then it belongs in the vhost headers.  The guest shouldn't see such
> a restriction if it doesn't apply; it's a host thing.
>
> Oh, and I think you could profitably use virtio_config_val(), too.

OK, I will make those changes. Thanks for the reference to
virtio_config_val(), I will use it in guest probe instead of
the cumbersome way I am doing now. Unfortunately I need a
constant in vhost for now.

Thanks,

- KK


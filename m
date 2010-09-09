From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC PATCH 1/4] Add a new API to virtio-pci
Date: Thu, 9 Sep 2010 21:44:25 +0930
Message-ID: <201009092144.26484.rusty@rustcorp.com.au>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com> <201009091319.40274.rusty@rustcorp.com.au> <OFB29E6C59.96686002-ON65257799.00174D50-65257799.001D6F7B@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: anthony@codemonkey.ws, davem@davemloft.net, kvm@vger.kernel.org,
	mst@redhat.com, netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <OFB29E6C59.96686002-ON65257799.00174D50-65257799.001D6F7B@in.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 9 Sep 2010 02:53:52 pm Krishna Kumar2 wrote:
> Rusty Russell <rusty@rustcorp.com.au> wrote on 09/09/2010 09:19:39 AM:
> 
> > On Wed, 8 Sep 2010 04:59:05 pm Krishna Kumar wrote:
> > > Add virtio_get_queue_index() to get the queue index of a
> > > vq.  This is needed by the cb handler to locate the queue
> > > that should be processed.
> >
> > This seems a bit weird.  I mean, the driver used vdev->config->find_vqs
> > to find the queues, which returns them (in order).  So, can't you put
> this
> > into your struct send_queue?
> 
> I am saving the vqs in the send_queue, but the cb needs
> to locate the device txq from the svq. The only other way
> I could think of is to iterate through the send_queue's
> and compare svq against sq[i]->svq, but cb's happen quite
> a bit. Is there a better way?

Ah, good point.  Move the queue index into the struct virtqueue?

> > Also, why define VIRTIO_MAX_TXQS?  If the driver can't handle all of
> them,
> > it should simply not use them...
> 
> The main reason was vhost :) Since vhost_net_release
> should not fail (__fput can't handle f_op->release()
> failure), I needed a maximum number of socks to
> clean up:

Ah, then it belongs in the vhost headers.  The guest shouldn't see such
a restriction if it doesn't apply; it's a host thing.

Oh, and I think you could profitably use virtio_config_val(), too.

Thanks!
Rusty.
